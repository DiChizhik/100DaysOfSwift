//
//  ViewController.swift
//  Project 4
//
//  Created by Diana Chizhik on 11/05/2022.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate  {
    var progressView: UIProgressView!
    var websites = [String]()
    var selectedWebsite: String?
    @IBOutlet var webView: WKWebView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: UIBarButtonItem.Style.plain, target: self, action: #selector (openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let goForwardButton = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector (webView.goForward))
        let goBackButton = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector (webView.goBack))
        progressView = UIProgressView(progressViewStyle: UIProgressView.Style.default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        toolbarItems = [goBackButton, goForwardButton, progressButton, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let url = URL(string: "https://www." + selectedWebsite!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    @objc func openTapped() {
        let alertController = UIAlertController(title: "Visit the website", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for website in websites {
        alertController.addAction(UIAlertAction(title: website, style: UIAlertAction.Style.default, handler: openPage))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
        present(alertController, animated: true)
    }
    
    func openPage (_ action: UIAlertAction) {
        let url = URL(string: "https://www." + action.title!)!
        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        let alertController = UIAlertController(title: "Blocked", message: "Accessing the requested website is not allowed", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel))
        present(alertController, animated: true)
        
        decisionHandler(.cancel)
        print("canceled")
    }
}

