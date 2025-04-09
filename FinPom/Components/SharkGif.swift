//
//  SharkGif.swift
//  FinPom
//
//  Created by Ali Jazzy Rasyid on 07/04/25.
//
import SwiftUI
import WebKit

struct GifImage: UIViewRepresentable {
    private let name: String
    
//initialize a name
    init(_ name: String){
        self.name = name
    }
   
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Set transparent background
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        if let url = Bundle.main.url(forResource: name, withExtension: "gif"),
           let data = try? Data(contentsOf: url) {
            webView.load(
                data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: url.deletingLastPathComponent()
            )
        }
        
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.reload()
    }

}

struct GifImage_Previews: PreviewProvider {
    static var previews: some View {
        GifImage("jeff")
    }
}

