//
//  ViewController.swift
//  Project 5
//
//  Created by Diana Chizhik on 13/05/2022.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    var lastGame = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the right part of the navigation bar
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(tappedInfo), for: UIControl.Event.touchUpInside)
        let infoBarButton = UIBarButtonItem(customView: infoButton)
        
        navigationItem.setRightBarButtonItems([addBarButton, infoBarButton], animated: true)
        
        // setting the left part of the navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(startGame))
        
        //uploading text from the file
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        readLastGame()
        if lastGame.isEmpty {
            startGame()
        } else {
            loadLastGame()
        }
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        lastGame.removeAll()
        usedWords.removeAll()
        tableView.reloadData()
        
        lastGame.append(title!)
        saveLastGame()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = usedWords[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    //method to open an alert controller to enter an answer
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter your answer" , message: nil, preferredStyle: UIAlertController.Style.alert)
        ac.addTextField()
        
        let submitAnswer = UIAlertAction(title: "Submit", style: UIAlertAction.Style.default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAnswer)
        present(ac, animated: true)
    }
    
    //method to display info about the game
    @objc func tappedInfo() {
        let ac = UIAlertController(title: "Anagrams", message: "An anagram is a word or phrase formed by rearranging the letters of a different word or phrase, using all the original letters exactly once.", preferredStyle: UIAlertController.Style.alert)
        ac.addAction(UIAlertAction(title: "Got it", style: UIAlertAction.Style.default))
        present(ac, animated: true)
    }
    
    //mothod to submit an answer to the tableview
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if answer != title {
            if isOriginal(lowerAnswer) {
                if isPossible(lowerAnswer) {
                    if isReal(lowerAnswer) {
                        usedWords.insert(lowerAnswer, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                        
                        lastGame.append(lowerAnswer)
                        saveLastGame()
                    
                        return
                    } else {
                    errorTitle = "Word not valid"
                    errorMessage = "You can't make up your own words!"
                    }
                } else {
                errorTitle = "Word not possible"
                errorMessage = "The word can't be made from \(title!)"
                }
            } else {
            errorTitle = "Word already used"
            errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Really?"
            errorMessage = "It is the initial word!"
        }
         
        showErrorMessage(title: errorTitle, message: errorMessage)
    }
    
    func isOriginal(_ answer: String) -> Bool {
        return !usedWords.contains(answer)
    }
    
    func isPossible(_ answer: String) -> Bool {
        guard var mainWord = title?.lowercased() else { return false }
        
        for letter in answer {
            if let position = mainWord.firstIndex(of: letter) {
                mainWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(_ answer: String) -> Bool {
        guard answer.utf16.count >= 3 else { return false }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: answer.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: answer, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        present(ac, animated: true)
    }
    
    func saveLastGame() {
        let jsonEncoder = JSONEncoder()
        if let savedGame = try? jsonEncoder.encode(lastGame) {
            let defaults = UserDefaults.standard
            defaults.set(savedGame, forKey: "lastGame")
        }
    }
    
    func readLastGame() {
        let defaults = UserDefaults.standard
        if let savedGame = defaults.object(forKey: "lastGame") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                lastGame = try jsonDecoder.decode([String].self, from: savedGame)
            } catch {
                print("Failed to load the last game.")
            }
        }
    }
    
    func loadLastGame() {
        title = lastGame[0]
        for word in lastGame[1..<lastGame.count] {
            usedWords.append(word)
        }
    }
    
}
