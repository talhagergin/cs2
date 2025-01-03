import Foundation

struct YouTubeURL: Codable {
    let urlString: String
    
    init(_ urlString: String) {
        // YouTube shorts URL'sini normal URL'ye çevirelim
        if urlString.contains("shorts/") {
            let videoID = urlString.components(separatedBy: "shorts/").last ?? ""
            self.urlString = "https://www.youtube.com/watch?v=\(videoID)"
        } else {
            self.urlString = urlString
        }
    }
    
    var embedURL: String {
        if let videoID = urlString.components(separatedBy: "v=").last {
            return "https://www.youtube.com/embed/\(videoID)"
        }
        return urlString
    }
} 