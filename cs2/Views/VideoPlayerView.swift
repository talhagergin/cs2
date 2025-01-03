import SwiftUI
import WebKit

struct VideoPlayerView: View {
    let url: String
    
    var body: some View {
        if let videoID = URLHelper.getVideoID(from: URLHelper.cleanYouTubeURL(url)) {
            YouTubePlayerView(videoID: videoID)
        } else {
            Text("Geçersiz video URL'si")
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
        }
    }
}

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let embedHTML = """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style>
                    body { margin: 0; }
                    .container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; }
                    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
                </style>
            </head>
            <body>
                <div class="container">
                    <iframe src="https://www.youtube.com/embed/\(videoID)" frameborder="0" allowfullscreen></iframe>
                </div>
            </body>
            </html>
        """
        
        uiView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: YouTubePlayerView
        
        init(_ parent: YouTubePlayerView) {
            self.parent = parent
        }
    }
} 