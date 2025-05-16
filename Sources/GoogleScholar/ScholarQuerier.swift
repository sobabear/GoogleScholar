import Foundation
import SwiftSoup

/// Main class for querying Google Scholar
public class ScholarQuerier {
    /// Array of articles from the most recent query
    public private(set) var articles = [ScholarArticle]()
    
    /// The most recent query
    public private(set) var query: ScholarQuery?
    
    /// URL session for making network requests
    private let session: URLSession
    
    /// Article parser for parsing HTML
    private let parser: ScholarArticleParser
    
    /// Cookie storage
    private let cookieStorage: HTTPCookieStorage
    
    /// Creates a new ScholarQuerier with optional custom URL session
    public init(session: URLSession = .shared) {
        self.session = session
        self.parser = ScholarArticleParser()
        self.cookieStorage = HTTPCookieStorage.shared
        
        // Load cookies from file if specified
        if let cookiePath = GoogleScholarConfig.shared.cookieFilePath {
            loadCookies(from: cookiePath)
        }
    }
    
    /// Loads cookies from a file
    private func loadCookies(from path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
               let cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookie] {
                for cookie in cookies {
                    cookieStorage.setCookie(cookie)
                }
                print("Loaded \(cookies.count) cookies from file")
            }
        }
    }
    
    /// Saves cookies to a file
    public func saveCookies() -> Bool {
        guard let cookiePath = GoogleScholarConfig.shared.cookieFilePath else {
            return false
        }
        
        if let cookies = cookieStorage.cookies,
           let data = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false) {
            do {
                try data.write(to: URL(fileURLWithPath: cookiePath))
                return true
            } catch {
                print("Error saving cookies: \(error)")
                return false
            }
        }
        
        return false
    }
    
    /// Performs a search with the given query using async/await
    @available(iOS 15.0, macOS 12.0, *)
    public func search(query: ScholarQuery) async throws -> [ScholarArticle] {
        return try await withCheckedThrowingContinuation { continuation in
            search(query: query) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Performs a search with the given query
    public func search(query: ScholarQuery, completion: @escaping (Result<[ScholarArticle], Error>) -> Void) {
        self.clearArticles()
        self.query = query
        let urlString = query.getUrl()
        guard !urlString.isEmpty else {
            completion(.failure(GoogleScholarError.invalidQuery("Query does not have enough parameters")))
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(GoogleScholarError.invalidFormat("Invalid URL: \(urlString)")))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(GoogleScholarConfig.shared.userAgent, forHTTPHeaderField: "User-Agent")

        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(GoogleScholarError.networkFailure(error)))
                return
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                completion(.failure(GoogleScholarError.parsingFailure("Parsing failure")))
                return
            }
            
            // Check if the response contains a CAPTCHA
            if html.contains("please show you're not a robot") || html.contains("Our systems have detected unusual traffic") {
                completion(.failure(GoogleScholarError.captchaRequired("Google Scholar is asking for a CAPTCHA. Try again later or use a different IP.")))
                return
            }
            
            do {
                let articles = try self.parse(html: html)
                
                // Update the query with the number of results
                if let numResults = self.parser.resultCount {
                    query.numResults = numResults
                }
                
                // Get citation data if needed
                self.fetchCitationData(for: articles) {
                    completion(.success(articles))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    /// Fetches citation data for the given articles using async/await
    @available(iOS 15.0, macOS 12.0, *)
    private func fetchCitationData(for articles: [ScholarArticle]) async {
        await withTaskGroup(of: Void.self) { group in
            for article in articles {
                if let citationUrl = article.citationUrl, let url = URL(string: citationUrl) {
                    group.addTask {
                        do {
                            var request = URLRequest(url: url)
                            request.addValue(GoogleScholarConfig.shared.userAgent, forHTTPHeaderField: "User-Agent")
                            
                            let (data, _) = try await self.session.data(for: request)
                            if let citationData = String(data: data, encoding: .utf8) {
                                article.citationData = citationData
                            }
                        } catch {
                            print("Error fetching citation data: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    /// Fetches citation data for the given articles
    private func fetchCitationData(for articles: [ScholarArticle], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for article in articles {
            if let citationUrl = article.citationUrl {
                guard let url = URL(string: citationUrl) else { continue }
                
                group.enter()
                
                var request = URLRequest(url: url)
                request.addValue(GoogleScholarConfig.shared.userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = session.dataTask(with: request) { data, response, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("Error fetching citation data: \(error)")
                        return
                    }
                    
                    guard let data = data, let citationData = String(data: data, encoding: .utf8) else {
                        return
                    }
                    
                    article.citationData = citationData
                }
                
                task.resume()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    /// Parses HTML content and updates articles
    public func parse(html: String) throws -> [ScholarArticle] {
        self.articles = try parser.parse(html: html)
        return self.articles
    }
    
    /// Clears any existing articles stored from previous queries
    public func clearArticles() {
        self.articles = []
    }
} 
