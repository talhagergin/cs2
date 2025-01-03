import Foundation

struct URLHelper {
    static func cleanYouTubeURL(_ url: String) -> String {
        // Boş URL kontrolü
        guard !url.isEmpty else { return "" }
        
        // URL'yi temizle
        var cleanURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanURL = cleanURL.replacingOccurrences(of: "@", with: "")
        
        // Video ID'sini çıkar
        if let videoID = cleanURL.components(separatedBy: "v=").last?.components(separatedBy: "&").first {
            return "https://www.youtube.com/watch?v=\(videoID)"
        }
        
        return url
    }
    
    static func getVideoID(from url: String) -> String? {
        let cleanURL = url.replacingOccurrences(of: "@", with: "")
        return cleanURL.components(separatedBy: "v=").last?.components(separatedBy: "&").first
    }
} 