//
//  DetailViewController.swift
//  Project 16
//
//  Created by Diana Chizhik on 06/06/2022.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet var webView: WKWebView!
    var selectedItem: Capital!
    let url = "https://en.wikipedia.org/wiki/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        if let capital = selectedItem {
            let capitalName = capital.title?.replacingOccurrences(of: " ", with: "_")
            if let url = URL(string: self.url + capitalName!) {
                webView.load(URLRequest(url: url))
                webView.allowsBackForwardNavigationGestures = true
            }
        }
    }
}
