import Foundation
import SwiftSoup

/// Class for parsing HTML content from Google Scholar
public class ScholarArticleParser {
    /// The base site URL
    private let baseUrl: String
    
    /// Regular expression for finding years
    private let yearRegex = try? NSRegularExpression(pattern: "\\b(?:20|19)\\d{2}\\b", options: [])
    
    /// Articles parsed from the HTML
    public var articles = [ScholarArticle]()
    
    /// Number of results found
    public var resultCount: Int?
    
    /// Creates a new parser with the given site
    public init(baseUrl: String? = nil) {
        self.baseUrl = baseUrl ?? GoogleScholarConfig.shared.baseUrl
    }
    
    /// Parses HTML content from Google Scholar
    public func parse(html: String) throws -> [ScholarArticle] {
        articles = []
        
        let document = try SwiftSoup.parse(html)
        
        // Parse global result attributes
        try parseGlobalStats(document: document)
        
        // Parse each article
        let resultDivs = try document.select("div.gs_r")
        for div in resultDivs {
            let article = try parseArticle(div: div)
            if article.title != nil {
                articles.append(article)
            }
        }
        
        return articles
    }
    
    /// Parses global result attributes
    private func parseGlobalStats(document: Document) throws {
        if let resultStats = try document.select("div#gs_ab_md").first() {
            let text = try resultStats.text()
            let components = text.components(separatedBy: .whitespaces)
            if components.count > 1 {
                let numberText = components[1].replacingOccurrences(of: ",", with: "")
                resultCount = Int(numberText)
            }
        }
    }
    
    /// Parses a single article div
    private func parseArticle(div: Element) throws -> ScholarArticle {
        let article = ScholarArticle()
        
        // Find and parse the title and URL
        if let h3 = try div.select("h3.gs_rt").first() {
            if let titleLink = try h3.select("a").first() {
                article.title = try titleLink.text()
                let href = try titleLink.attr("href")
                article.url = convertToAbsoluteUrl(path: href)
                
                if href.hasSuffix(".pdf") {
                    article.pdfUrl = article.url
                }
            } else {
                // This is a "CITATION" entry without a link
                // Remove spans with unneeded content
                let h3Clone = h3.copy() as? Element
                if let h3Copy = h3Clone {
                    try h3Copy.select("span").remove()
                    article.title = try h3Copy.text()
                } else {
                    article.title = try h3.text()
                }
            }
        }
        
        // Find and parse the year
        if let yearDiv = try div.select("div.gs_a").first() {
            let yearText = try yearDiv.text()
            if let regex = yearRegex, let match = regex.firstMatch(in: yearText, range: NSRange(yearText.startIndex..., in: yearText)) {
                let yearRange = Range(match.range, in: yearText)!
                article.year = Int(yearText[yearRange])
            }
        }
        
        // Find and parse links (citations, versions, etc.)
        if let linksDiv = try div.select("div.gs_fl").first() {
            try parseLinks(container: linksDiv, article: article)
        }
        
        // Find and parse excerpt
        if let excerptDiv = try div.select("div.gs_rs").first() {
            article.excerpt = try excerptDiv.text()
                .replacingOccurrences(of: "\n", with: "")
        }
        
        return article
    }
    
    /// Parses links in an article
    private func parseLinks(container: Element, article: ScholarArticle) throws {
        let links = try container.select("a")
        
        for link in links {
            let href = try link.attr("href")
            
            if href.starts(with: "/scholar?cites") {
                let linkText = try link.text()
                if linkText.starts(with: "Cited by") {
                    let components = linkText.components(separatedBy: .whitespaces)
                    if let last = components.last, let citations = Int(last) {
                        article.citations = citations
                    }
                }
                
                article.citationsUrl = stripQueryParam(name: "num", url: convertToAbsoluteUrl(path: href))
                
                // Extract cluster ID
                if let citationsUrl = article.citationsUrl, let queryString = citationsUrl.components(separatedBy: "?").last {
                    let queryItems = queryString.components(separatedBy: "&")
                    for item in queryItems {
                        if item.starts(with: "cites=") {
                            article.clusterId = String(item.dropFirst(6))
                            break
                        }
                    }
                }
            }
            
            if href.starts(with: "/scholar?cluster") {
                let linkText = try link.text()
                if linkText.starts(with: "All ") {
                    let components = linkText.components(separatedBy: .whitespaces)
                    if components.count > 1, let versions = Int(components[1]) {
                        article.versions = versions
                    }
                }
                
                article.versionsUrl = stripQueryParam(name: "num", url: convertToAbsoluteUrl(path: href))
            }
            
            let linkText = try link.text()
            if linkText.starts(with: "Import") {
                article.citationUrl = convertToAbsoluteUrl(path: href)
            }
        }
    }
    
    /// Converts a path to a full URL
    private func convertToAbsoluteUrl(path: String) -> String {
        if path.starts(with: "http://") || path.starts(with: "https://") {
            return path
        }
        
        var fullPath = path
        if !path.starts(with: "/") {
            fullPath = "/" + path
        }
        
        return baseUrl + fullPath
    }
    
    /// Strips a URL-encoded argument from a URL
    private func stripQueryParam(name: String, url: String) -> String {
        let components = url.components(separatedBy: "?")
        if components.count != 2 {
            return url
        }
        
        let base = components[0]
        let query = components[1]
        
        let queryItems = query.components(separatedBy: "&")
        let filteredItems = queryItems.filter { !$0.starts(with: "\(name)=") }
        
        return base + "?" + filteredItems.joined(separator: "&")
    }
} 
