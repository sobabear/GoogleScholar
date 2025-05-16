import Foundation

public class ScholarArticle: Identifiable, Codable {
    // MARK: - Properties
    public let id = UUID()
    public var title: String?
    public var url: String?
    public var year: Int?
    public var citations: Int = 0
    public var versions: Int = 0
    public var clusterId: String?
    public var pdfUrl: String?
    public var citationsUrl: String?
    public var versionsUrl: String?
    public var citationUrl: String?
    public var excerpt: String?
    
    // Citation data in a standard format (BibTeX, etc.)
    public var citationData: String?
    
    // MARK: - Initialization
    public init(
        title: String? = nil,
        url: String? = nil,
        year: Int? = nil,
        citations: Int = 0,
        versions: Int = 0,
        clusterId: String? = nil,
        pdfUrl: String? = nil,
        citationsUrl: String? = nil,
        versionsUrl: String? = nil,
        citationUrl: String? = nil,
        excerpt: String? = nil
    ) {
        self.title = title
        self.url = url
        self.year = year
        self.citations = citations
        self.versions = versions
        self.clusterId = clusterId
        self.pdfUrl = pdfUrl
        self.citationsUrl = citationsUrl
        self.versionsUrl = versionsUrl
        self.citationUrl = citationUrl
        self.excerpt = excerpt
    }
    
    // MARK: - Output Formats
    
    /// Returns the article formatted as text
    public func asText() -> String {
        var result: [String] = []
        
        // Calculate max label length for formatting
        let labels = ["Title", "URL", "Year", "Citations", "Versions", 
                     "Cluster ID", "PDF link", "Citations list", 
                     "Versions list", "Citation link", "Excerpt"]
        let maxLength = labels.map { $0.count }.max() ?? 0
        
        // Add properties if they have values
        if let title = title {
            result.append(String(format: "%-\(maxLength)s %@", "Title:", title))
        }
        
        if let url = url {
            result.append(String(format: "%-\(maxLength)s %@", "URL:", url))
        }
        
        if let year = year {
            result.append(String(format: "%-\(maxLength)s %d", "Year:", year))
        }
        
        if citations > 0 {
            result.append(String(format: "%-\(maxLength)s %d", "Citations:", citations))
        }
        
        if versions > 0 {
            result.append(String(format: "%-\(maxLength)s %d", "Versions:", versions))
        }
        
        if let clusterId = clusterId {
            result.append(String(format: "%-\(maxLength)s %@", "Cluster ID:", clusterId))
        }
        
        if let pdfUrl = pdfUrl {
            result.append(String(format: "%-\(maxLength)s %@", "PDF link:", pdfUrl))
        }
        
        if let citationsUrl = citationsUrl {
            result.append(String(format: "%-\(maxLength)s %@", "Citations list:", citationsUrl))
        }
        
        if let versionsUrl = versionsUrl {
            result.append(String(format: "%-\(maxLength)s %@", "Versions list:", versionsUrl))
        }
        
        if let citationUrl = citationUrl {
            result.append(String(format: "%-\(maxLength)s %@", "Citation link:", citationUrl))
        }
        
        if let excerpt = excerpt {
            result.append(String(format: "%-\(maxLength)s %@", "Excerpt:", excerpt))
        }
        
        return result.joined(separator: "\n")
    }
        
}
