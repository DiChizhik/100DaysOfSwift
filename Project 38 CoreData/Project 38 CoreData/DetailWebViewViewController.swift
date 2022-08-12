//
//  DetailWebViewViewController.swift
//  Project 38 CoreData
//
//  Created by Diana Chizhik on 14/07/2022.
//

import UIKit
import WebKit

class DetailWebViewViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    var urlString: String?
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let urlString = urlString {
            if let url = URL(string: urlString) {
                webView.load(URLRequest(url: url))
            }
        }
    }
    

}
