//
//  ViewController.swift
//  Project2
//
//  Created by Diana Chizhik on 09/05/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    
    var score = 0
    var savedScore = 0
    
    var correctAnswer = 0
    var numberOfAskedQuestions = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(showScore))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadGame))
        
        for button in [button1, button2, button3] {
            button!.layer.borderWidth = 1
            button!.layer.borderColor = UIColor.lightGray.cgColor
            button!.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
        
        loadSavedScore()
        
        loadGame()
        
        setupNotifications()
    }

    @objc func loadGame() {
        score = 0
        numberOfAskedQuestions = 0
        askQuestion()
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        for button in [button1, button2, button3] {
            button?.transform = .identity
        }
        
        title = countries[correctAnswer].uppercased() + " - your current score is \(score)"
        numberOfAskedQuestions += 1
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5,
                       options: [],
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        },
                       completion: nil)
        
        if sender.tag == correctAnswer {
            score += 1
    
            if numberOfAskedQuestions == 10 {
                saveScore()
            } else {
                showAlertAboutCurrentScore(title: "Well done!", message: "Your score is now \(score).")
            }
        } else {
            score -= 1
            
            if numberOfAskedQuestions == 10 {
                saveScore()
            } else {
                showAlertAboutCurrentScore(title: "Oops!", message: "This the flag of \(countries[sender.tag].uppercased()). Your score is now \(score).")
            }
        }
    }
    
    @objc func showScore (_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Score", message: "Your current score is \(score).\n You record is \(savedScore).", preferredStyle: UIAlertController.Style.alert)
        ac.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel, handler: { (action) in self.dismiss(animated: true, completion: nil)}))
        present(ac, animated: true)
    }
    
    func showAlertAboutCurrentScore(title: String, message: String) {
        let correctAc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        correctAc.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(correctAc, animated: true)
    }
    
    func saveScore() {
        if savedScore >= score {
            let finalAc = UIAlertController(title: "Final score", message: "Your score is \(score)", preferredStyle: UIAlertController.Style.alert)
            finalAc.addAction(UIAlertAction(title: "OK", style: .default))
            present(finalAc, animated: true)
        } else {
            savedScore = score
            
            DispatchQueue.global(qos: .default).async {
                let jsonEncoder = JSONEncoder()
                if let savedScore = try? jsonEncoder.encode(self.savedScore) {
                    let defaults = UserDefaults.standard
                    defaults.set(savedScore, forKey: "savedScore")
                }
            }
            
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "New record", message: "Your new record is \(self.savedScore) points!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Hoorah!", style: .default))
                self.present(ac, animated: true)
            }
        }
    }
    
    func loadSavedScore() {
        let defaults = UserDefaults.standard
        
        if let savedScore = defaults.object(forKey: "savedScore") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                self.savedScore = try jsonDecoder.decode(Int.self, from: savedScore)
            } catch {
                print("Failed to load score.")
            }
        }
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func requestNotificationsPermission() {
        let centre = UNUserNotificationCenter.current()
        centre.requestAuthorization(options: [.alert, .badge, .sound]) {
           [weak self] permissionGranted, error in
            if permissionGranted {
                print("Permission granted")
                self?.scheduleReminder()
            } else {
                print("Permission denied")
            }
        }
    }
    
    func scheduleReminder() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Flags"
        content.body = "Practice recognizing countries' flags"
        content.categoryIdentifier = "flags"
        content.sound = .default
        
        for i in 1...7 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10 * Double(i), repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        requestNotificationsPermission()
    }
    
//    func registerCategories() {
//        let center = UNUserNotificationCenter.current()
//        center.delegate = self
//
//        let remind = UNNotificationAction(identifier: "remind", title: "")
//
//        let category = UNNotificationCategory(identifier: "flags", actions: <#T##[UNNotificationAction]#>, intentIdentifiers: <#T##[String]#>, options: <#T##UNNotificationCategoryOptions#>)
//        center.setNotificationCategories([])
//    }
    
}

