import XCTest
@testable import GoogleScholar

final class GoogleScholarTests: XCTestCase {
    func testQueryConstruction() {
        let query = ScholarQuery()
        query.author = "Albert Einstein"
        query.phrase = "quantum theory"
        query.limit = 5
        
        XCTAssertEqual(query.author, "Albert Einstein")
        XCTAssertEqual(query.phrase, "quantum theory")
        XCTAssertEqual(query.limit, 5)
        
        let url = query.getUrl()
        print("😇 \(url)")
        XCTAssertTrue(url.contains("as_sauthors=Albert%20Einstein"))
        XCTAssertTrue(url.contains("as_epq=quantum%20theory"))
    }
    
    func testQueryAndSearchConstruction() {
        let query = ScholarQuery()
        let expectation = XCTestExpectation(description: "Perform search")
        query.author = "Albert Einstein"
        query.phrase = "quantum theory"
        query.limit = 5
        
        XCTAssertEqual(query.author, "Albert Einstein")
        XCTAssertEqual(query.phrase, "quantum theory")
        XCTAssertEqual(query.limit, 5)
        
        let url = query.getUrl()
        let querier = ScholarQuerier()
        querier.search(query: query) { result in
            switch result {
            case let .success(articles):
                print("😇 \(articles.map({ ($0.title, $0.year, $0.url) }))")
                expectation.fulfill()
            case let .failure(error):
                XCTFail("Search failed with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testSearchQuery() {
        // This test would require network access, so we'll keep it simple
        // In a real implementation, you might want to use a mock network service
        let expectation = XCTestExpectation(description: "Perform search")
        
        let query = ScholarQuery()
        query.phrase = "test"
        query.limit = 1
        
        let querier = ScholarQuerier()
        querier.search(query: query) { result in
            switch result {
            case let .success(articles):
                XCTAssertTrue(articles.count <= 1)
                expectation.fulfill()
            case let .failure(error):
                XCTFail("Search failed with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
} 
