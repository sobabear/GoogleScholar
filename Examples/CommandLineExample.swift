import Foundation
import GoogleScholar

// This example mirrors the functionality of the Python script
// Usage: swift CommandLineExample.swift [options] <query>

// Function to print usage info
func printUsage() {
    print("Usage: swift CommandLineExample.swift [options] <query>")
    print("Options:")
    print("  -a, --author AUTHOR     Author name")
    print("  -p, --phrase PHRASE     Search for exact phrase")
    print("  -t, --title-only        Search in title only")
    print("  -c, --count COUNT       Maximum number of results (default: 10)")
    print("  --after YEAR            Results must have appeared in or after given year")
    print("  --before YEAR           Results must have appeared in or before given year")
    print("  --cookie-file FILE      File to store/load cookies")
    print("  -h, --help              Show this help message")
}

// Parse command line arguments
func parseArguments() -> (ScholarQuery, String?) {
    let query = ScholarQuery()
    var cookieFile: String?
    
    var args = Array(CommandLine.arguments.dropFirst())
    
    // Check if help is requested
    if args.contains("-h") || args.contains("--help") || args.isEmpty {
        printUsage()
        exit(0)
    }
    
    var i = 0
    while i < args.count {
        let arg = args[i]
        
        if arg == "-a" || arg == "--author", i + 1 < args.count {
            query.author = args[i + 1]
            i += 2
        } else if arg == "-p" || arg == "--phrase", i + 1 < args.count {
            query.phrase = args[i + 1]
            i += 2
        } else if arg == "-t" || arg == "--title-only" {
            query.scopeTitle = true
            i += 1
        } else if arg == "-c" || arg == "--count", i + 1 < args.count {
            query.limit = Int(args[i + 1])
            i += 2
        } else if arg == "--after", i + 1 < args.count {
            query.startYear = Int(args[i + 1])
            i += 2
        } else if arg == "--before", i + 1 < args.count {
            query.endYear = Int(args[i + 1])
            i += 2
        } else if arg == "--cookie-file", i + 1 < args.count {
            cookieFile = args[i + 1]
            GoogleScholarConfig.shared.cookieFilePath = args[i + 1]
            i += 2
        } else if arg.hasPrefix("-") {
            print("Unknown option: \(arg)")
            printUsage()
            exit(1)
        } else {
            // Assume it's a search query if it doesn't start with -
            query.words = arg
            i += 1
        }
    }
    
    return (query, cookieFile)
}

// Main function
func main() {
    let (query, cookieFile) = parseArguments()
    
    // Validate query has enough parameters
    if query.words == nil && query.wordsSome == nil && query.wordsNone == nil && 
       query.phrase == nil && query.author == nil && query.pub == nil &&
       query.startYear == nil && query.endYear == nil {
        print("Error: Not enough search parameters specified.")
        printUsage()
        exit(1)
    }
    
    // Create querier and perform search
    let querier = ScholarQuerier()
    
    print("Searching Google Scholar...")
    
    let semaphore = DispatchSemaphore(value: 0)
    
    querier.search(query: query) { result in
        switch result {
        case .success(let articles):
            print("Found \(articles.count) articles")
            
            for article in articles {
                print("\n----------------------------------------")
                print(article.asText())
            }
            
        case .failure(let error):
            print("Error: \(error)")
        }
        
        // Save cookies if requested
        if cookieFile != nil {
            if querier.saveCookies() {
                print("Cookies saved to \(cookieFile!)")
            } else {
                print("Failed to save cookies")
            }
        }
        
        semaphore.signal()
    }
    
    // Wait for completion
    semaphore.wait()
}

// Run the main function
main() 