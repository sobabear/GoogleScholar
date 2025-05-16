import Foundation

/// Configuration settings for ScholarSwift
public class GoogleScholarConfig {
    /// Singleton instance
    public static let shared = GoogleScholarConfig()
    
    /// Version of the ScholarSwift package
    public let version = "1.0.0"
    
    /// Log level for debug output
    public var logLevel = 1
    
    /// Maximum number of results per page
    public var maxResultsPerPage = 10
    
    /// Base URL for Google Scholar
    public let baseUrl = "https://scholar.google.com"

    public var userAgent: String = "Mozilla/5.0 (X11; Linux x86_64; rv:27.0) Gecko/20100101 Firefox/27.0"

    /// Optional path to a cookie jar file
    public var cookieFilePath: String?
    
    private init() {}
} 
