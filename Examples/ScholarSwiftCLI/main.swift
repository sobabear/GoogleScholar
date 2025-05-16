import Foundation
import ScholarSwift

// Simple command-line interface for ScholarSwift
print("ScholarSwift Command Line Interface")
print("----------------------------------\n")

// Create a query
let query = ScholarQuery()

// Process command-line arguments
var i = 1
while i < CommandLine.arguments.count {
    let arg = CommandLine.arguments[i]
    
    switch arg {
    case "--author", "-a":
        if i + 1 < CommandLine.arguments.count {
            query.author = CommandLine.arguments[i + 1]
            i += 1
        }
    case "--phrase", "-p":
        if i + 1 < CommandLine.arguments.count {
            query.phrase = CommandLine.arguments[i + 1]
            i += 1
        }
    case "--words", "-w":
        if i + 1 < CommandLine.arguments.count {
            query.words = CommandLine.arguments[i + 1]
            i += 1
        }
    case "--limit", "-l":
        if i + 1 < CommandLine.arguments.count {
            query.limit = Int(CommandLine.arguments[i + 1])
            i += 1
        }
    case "--title-only", "-t":
        query.scopeTitle = true
    case "--help", "-h":
        print("Usage: ScholarSwiftCLI [options]")
        print("Options:")
        print("  --author, -a <name>     Search for articles by this author")
        print("  --phrase, -p <phrase>   Search for articles containing this exact phrase")
        print("  --words, -w <words>     Search for articles containing these words")
        print("  --limit, -l <number>    Limit the number of results")
        print("  --title-only, -t        Search in title only")
        print("  --help, -h              Show this help message")
        exit(0)
    default:
        print("Unknown argument: \(arg)")
        exit(1)
    }
    
    i += 1
}

// Check if we have enough parameters
if query.author == nil && query.phrase == nil && query.words == nil {
    print("Error: You must specify at least one search parameter (author, phrase, or words).")
    print("Use --help for more information.")
    exit(1)
}

// Print the query
print("Searching for:")
if let author = query.author {
    print("- Author: \(author)")
}
if let phrase = query.phrase {
    print("- Phrase: \(phrase)")
}
if let words = query.words {
    print("- Words: \(words)")
}
if let limit = query.limit {
    print("- Limit: \(limit)")
}
if query.scopeTitle {
    print("- Searching in title only")
}

print("\nFetching results...\n")

// Perform the search
let querier = ScholarQuerier()
querier.search(query: query) { result in
    switch result {
    case .success(let articles):
        print("Found \(articles.count) articles:")
        
        for (index, article) in articles.enumerated() {
            print("\n--- Article \(index + 1) ---")
            if let title = article.title {
                print("Title: \(title)")
            }
            if let url = article.url {
                print("URL: \(url)")
            }
            if let year = article.year {
                print("Year: \(year)")
            }
            print("Citations: \(article.numCitations)")
            
            if let excerpt = article.excerpt {
                print("Excerpt: \(excerpt)")
            }
        }
        
        if let numResults = query.numResults {
            print("\nTotal results found: \(numResults)")
        }
        
    case .failure(let error):
        print("Error: \(error)")
    }
    
    exit(0)
}

// Keep the program running to allow the asynchronous request to complete
RunLoop.main.run() 