import Foundation
import GoogleScholar

// Simple example of using GoogleScholar

// Create a query
let query = ScholarQuery()
query.author = "Albert Einstein"
query.phrase = "quantum theory"
query.limit = 5

// Create a querier and perform the search
let querier = ScholarQuerier()
print("Searching for papers by Albert Einstein on quantum theory...")

// For Swift 5.5 and newer with async/await support
if #available(macOS 12.0, iOS 15.0, *) {
    Task {
        do {
            let articles = try await querier.search(query: query)
            print("Found \(articles.count) articles:")
            for article in articles {
                print("\nTitle: \(article.title ?? "Unknown")")
                print("URL: \(article.url ?? "N/A")")
                print("Year: \(article.year.map(String.init) ?? "Unknown")")
                print("Citations: \(article.citations)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
} else {
    // For older Swift versions using completion handlers
    querier.search(query: query) { result in
        switch result {
        case .success(let articles):
            print("Found \(articles.count) articles:")
            for article in articles {
                print("\nTitle: \(article.title ?? "Unknown")")
                print("URL: \(article.url ?? "N/A")")
                print("Year: \(article.year.map(String.init) ?? "Unknown")")
                print("Citations: \(article.citations)")
            }
        case .failure(let error):
            print("Error: \(error)")
        }
    }
    
    // Keep the program running to allow the network request to complete
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 30))
} 