# ScholarSwift

A Swift package for querying Google Scholar and parsing returned results. This package allows you to search Google Scholar, retrieve paper information, and access citation data from iOS, iPadOS, and macOS applications.

## Features

- Search Google Scholar with various query parameters (author, keywords, publication, etc.)
- Retrieve article metadata (title, URL, year, citations, etc.)
- Parse citation data in various formats
- Support for advanced search options

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file's dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/sobabear/GoogleScholar.git", from: "1.0.0")
]
```

Or add it directly through Xcode: File > Swift Packages > Add Package Dependency...

## Usage

```swift
import GoogleScholar

// Create a search query
let query = ScholarQuery()
query.author = "Albert Einstein"
query.phrase = "quantum theory"
query.limit = 5

// Create a querier and perform the search
let querier = ScholarQuerier()
querier.search(query: query) { result in
    switch result {
    case .success(let articles):
        for article in articles {
            print(article.title)
            print(article.url)
            print(article.year)
            print(article.citations)
        }
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Using Async/Await

The package also supports Swift's modern concurrency model with async/await:

```swift
import GoogleScholar

// Create a search query
let query = ScholarQuery()
query.author = "Albert Einstein"
query.phrase = "quantum theory"
query.limit = 5

// Create a querier and perform the search using async/await
let querier = ScholarQuerier()
do {
    let articles = try await querier.search(query: query)
    for article in articles {
        print(article.title)
        print(article.url)
        print(article.year)
        print(article.citations)
    }
} catch {
    print("Error: \(error)")
}
```

### Command Line Usage

The package includes a command line example that mimics the functionality of the original Python script. You can find it in the Examples directory.

```bash
# Compile the example
swiftc -I .build/debug -L .build/debug -lGoogleScholar Examples/CommandLineExample.swift -o scholar

# Search for papers by Einstein on quantum theory
./scholar -a "Albert Einstein" -p "quantum theory"

# Limit to 5 results, title only search
./scholar -c 5 -t -a "Albert Einstein"

# Search with year constraints
./scholar --after 1950 --before 1970 -a "Albert Einstein"

# Use cookies to maintain session
./scholar --cookie-file cookies.txt -a "Albert Einstein"
```

## Requirements

- iOS 13.0+
- iPadOS 13.0+
- macOS 10.15+
- Xcode 13.0+
- Swift 5.5+

## Note

This is a Swift port of the Python [scholar.py](https://github.com/ckreibich/scholar.py) package by Christian Kreibich.

## License

This package is available under the BSD license. See the LICENSE file for more info. 