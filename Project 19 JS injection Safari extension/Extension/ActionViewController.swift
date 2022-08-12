//
//  ActionViewController.swift
//  Extension
//
//  Created by Diana Chizhik on 13/06/2022.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController, ScriptsTableViewControllerDelegate {
    @IBOutlet var script: UITextView!
    
    private let dataHandlingService = DataHandlingService()
    private let getHostService = GetHostService()
    
    var pageTitle = ""
    var pageURL = ""
    var scripts = [Script]()
    var selectedScript: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = doneButton
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        let seeOptionsButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(seeOptionsTapped))
        navigationItem.rightBarButtonItems = [seeOptionsButton, saveButton]
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        
                        if let host = self?.getHostService.getHost(urlString: self!.pageURL) {
                            if let scriptToLoad = self?.dataHandlingService.loadScriptFromUserDefaults(withKey: host) {
                                self?.script.text = scriptToLoad
                            }
                        }
                    }
                }
            }
        }
        
        if let scriptsToLoad = dataHandlingService.loadScriptsFromUserDefaults(withKey: "scripts") {
            scripts = scriptsToLoad
        }

        let notificationCentre = NotificationCenter.default
        notificationCentre.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCentre.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text!]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaProvider = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier)
        item.attachments = [customJavaProvider]
        
        extensionContext?.completeRequest(returningItems: [item])
        
        if let host = getHostService.getHost(urlString: pageURL) {
            dataHandlingService.saveScriptToUserDefaults(script.text, withKey: host)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
     
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = UIEdgeInsets.zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func saveTapped() {
        guard let script = script.text else { return }
        
        let ac = UIAlertController(title: "Name your script", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak ac]action in
            guard let name = ac?.textFields?[0].text else { return }
            let script = Script(name: name, scriptText: script)
            
            self?.scripts.append(script)
            self?.dataHandlingService.saveScriptsToUserDefaults(self!.scripts, withKey: "scripts")
        })
        ac.addAction(UIAlertAction(title: "Back", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func seeOptionsTapped() {
        let tableViewController = ScriptsTableViewController()
        tableViewController.delegate = self
        navigationController?.pushViewController(tableViewController, animated: true)
    }
    
    func didChooseScript(_ tableView: UITableView, _ script: Script) {
        self.script.text = script.scriptText
    }

}
