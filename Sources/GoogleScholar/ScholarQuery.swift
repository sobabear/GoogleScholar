import Foundation

/// Base class for any kind of results query sent to Scholar
public class ScholarQuery {
    /// Words that all must be found in the results
    public var words: String?
    
    /// Words of which at least one must be found in the results
    public var wordsSome: String?
    
    /// Words of which none must be found in the results
    public var wordsNone: String?
    
    /// Phrase that must be found in the results exactly
    public var phrase: String?
    
    /// Whether to search in the title only
    public var scopeTitle = false
    
    /// Author names that must be on the result's author list
    public var author: String?
    
    /// Publication in which the result must be found
    public var pub: String?
    
    /// Start year for timeframe filtering
    public var startYear: Int?
    
    /// End year for timeframe filtering
    public var endYear: Int?
    
    /// Whether to include patents in results
    public var includePatents = true
    
    /// Whether to include citations in results
    public var includeCitations = true
    
    /// Maximum number of results to return
    public var limit: Int?
    
    /// Number of results found (set after query is executed)
    public var numResults: Int = 0
    
    /// Cluster ID for retrieving a specific article cluster
    public var clusterId: String?
    
    /// Creates a new, empty ScholarQuery
    public init() {}
    
    /// Returns a complete, submittable URL string for this query
    public func getUrl() -> String {
        if clusterId != nil {
            return getClusterUrl()
        } else {
            return getSearchUrl()
        }
    }
    
    /// Returns a URL for a cluster query
    private func getClusterUrl() -> String {
        guard let clusterId = clusterId else {
            return ""
        }
        
        var url = "\(GoogleScholarConfig.shared.baseUrl)/scholar?cluster=\(clusterId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let limit = limit {
            url += "&num=\(limit)"
        }
        
        return url
    }
    
    /// Returns a URL for a search query
    private func getSearchUrl() -> String {
        // Check if we have enough parameters
        if words == nil && wordsSome == nil && wordsNone == nil && phrase == nil &&
           author == nil && pub == nil && startYear == nil && endYear == nil {
            return ""
        }
        
        // Build the URL
        var url = "\(GoogleScholarConfig.shared.baseUrl)/scholar?as_q=\(words?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        // Add the rest of the parameters
        url += "&as_epq=\(phrase?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        url += "&as_oq=\(wordsSome?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        url += "&as_eq=\(wordsNone?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        url += "&as_occt=\(scopeTitle ? "title" : "any")"
        url += "&as_sauthors=\(author?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        url += "&as_publication=\(pub?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let startYear = startYear {
            url += "&as_ylo=\(startYear)"
        }
        
        if let endYear = endYear {
            url += "&as_yhi=\(endYear)"
        }
        
        url += "&as_vis=\(includeCitations ? "0" : "1")"
        url += "&as_sdt=\(includePatents ? "0" : "1")%2C5"
        url += "&btnG=&hl=en"
        
        if let limit = limit {
            url += "&num=\(limit)"
        }
        
        return url
    }
} 
