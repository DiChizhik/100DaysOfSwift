//
//  ViewController.swift
//  Keychain
//
//  Created by Diana Chizhik on 06/07/2022.
//
import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    @IBOutlet var secretTextView: UITextView!
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(saveSecretText), for: .touchUpInside)
        doneButton.isHidden = true
        return doneButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "No data to display"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretText), name: UIApplication.willResignActiveNotification, object: nil)
        
        setPassword()
    }
    
    private func setPassword() {
        guard KeychainWrapper.standard.string(forKey: "password") == nil else { return }
        
        let ac = UIAlertController(title: "Set password", message: "Enter a password to access the app", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak ac] _ in
            guard let password = ac?.textFields?[0].text else { return }
            KeychainWrapper.standard.set(password, forKey: "password")
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        present(ac, animated: true)
    }

    @IBAction func authenticationTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, error) in
                
                DispatchQueue.main.async {
                    if success {
                        self?.loadSecretText()
                    } else {
                        self?.showError(title: "Authentication failed", message: "You couldn't be verified. Please try again.")
                    }
                }
            }
        } else {
            showError(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.")
        }
    }
    
    private func showError(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        ac.addAction(UIAlertAction(title: "Enter password", style: .default, handler: enterPassword))
        present(ac, animated: true)
    }
    
    private func enterPassword(_ action: UIAlertAction) {
        let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak self, weak ac] _ in
            guard let enteredPassword = ac?.textFields?[0].text else { return }
            guard let password = KeychainWrapper.standard.string(forKey: "password") else { return }
            
            if password == enteredPassword {
                self?.loadSecretText()
            } else {
                return
            }
        })
        present(ac, animated: true)
    }
    
    private func loadSecretText() {
        secretTextView.isHidden = false
        title = "Secret info"
        doneButton.isHidden = false
        
        secretTextView.text = KeychainWrapper.standard.string(forKey: "secretText") ?? ""
    }
    
    @objc private func saveSecretText() {
        guard secretTextView.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secretTextView.text, forKey: "secretText")
        secretTextView.resignFirstResponder()
        secretTextView.isHidden = true
        doneButton.isHidden = true
        title = "No data to display"
    }
    
    @objc private func adjustForKeyboard(_ notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secretTextView.contentInset = .zero
        } else {
            secretTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secretTextView.scrollIndicatorInsets = secretTextView.contentInset
        
        let selectedRange = secretTextView.selectedRange
        secretTextView.scrollRangeToVisible(selectedRange)
    }
}

