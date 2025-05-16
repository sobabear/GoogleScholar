import Foundation

/// Errors that can occur when using the ScholarSwift package
public enum GoogleScholarError: Error {
    /// General error
    case general(String)
    
    /// Format error - a query argument or setting was formatted incorrectly
    case invalidFormat(String)
    
    /// Query error - a query did not have a suitable set of arguments
    case invalidQuery(String)
    
    /// Network error
    case networkFailure(Error)
    
    /// Parsing error
    case parsingFailure(String)
    
    /// CAPTCHA required
    case captchaRequired(String)
} 