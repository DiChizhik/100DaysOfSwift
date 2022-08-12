//
//  ViewController.swift
//  Project 8
//
//  Created by Diana Chizhik on 18/05/2022.
//

import UIKit

class ViewController: UIViewController {
    var scoreLabel: UILabel!
    var answersLabel: UILabel!
    var cluesLabel: UILabel!
    var currentAnswer: UITextField!
    var letterButtons = [UIButton]()
    
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var level = 1
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var correctAnswers = 0
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Score: \(score)"
        scoreLabel.textAlignment = .right
        view.addSubview(scoreLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.text = "Answers"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .left
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.text = "Clues"
        cluesLabel.numberOfLines = 0
        cluesLabel.textAlignment = .right
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.isUserInteractionEnabled = false
        currentAnswer.placeholder = "Add answers here"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        view.addSubview(currentAnswer)
        
        let submitButton = UIButton(type: .system)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        view.addSubview(submitButton)
        
        let clearButton = UIButton(type: .system)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("Clear", for: .normal)
        view.addSubview(clearButton)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.layer.borderWidth = 1
        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            
            cluesLabel.heightAnchor.constraint(equalTo: answersLabel.heightAnchor),
            
            currentAnswer.topAnchor.constraint(equalTo: answersLabel.bottomAnchor, constant: 20),
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            submitButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clearButton.heightAnchor.constraint(equalTo: submitButton.heightAnchor),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        let width = 150
        let height = 80
        
        for row in 0..<4 {
            for column in 0..<5 {
                let button = UIButton(type: .system)
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                button.setTitle("WWW", for: .normal)
                let frame = CGRect(x: width * column, y: height * row, width: width, height: height)
                button.frame = frame
                
                buttonsView.addSubview(button)
                
                letterButtons.append(button)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos:.userInteractive).async {
            self.loadLevel()
        }
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        guard let currentAnswerText = currentAnswer.text  else { return }
        
        if let solutionPosition = solutions.firstIndex(of: currentAnswerText) {
            activatedButtons.removeAll()
                
            var splitAnswer = cluesLabel.text?.components(separatedBy: "\n")
            splitAnswer?[solutionPosition] = currentAnswerText
            cluesLabel.text = splitAnswer?.joined(separator: "\n")
                
            currentAnswer.text = ""
            score += 1
            correctAnswers += 1
        } else {
            let ac = UIAlertController(title: "Oops", message: "The answer is wrong", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
                
            for button in activatedButtons {
                animateButtons(button: button, buttonAlpha: 1, buttonsArrayAction: nil)
            }
           
            activatedButtons.removeAll()
            currentAnswer.text = ""
                
            score -= 1
        }
        
        if correctAnswers % 7 == 0 {
            let ac = UIAlertController(title: "Good job!", message: "Ready for the next level?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Let go!", style: .default, handler: levelUp))
            present(ac, animated: true)
        }
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        
        for button in activatedButtons {
            animateButtons(button: button, buttonAlpha: 1, buttonsArrayAction: nil)
        }
        
        activatedButtons.removeAll()
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else {return}
        currentAnswer.text = currentAnswer.text?.appending(buttonText)
        animateButtons(button: sender, buttonAlpha: 0.1, buttonsArrayAction: "append")
        }

    func loadLevel() {
        var clueString = ""
        var solutionsString = ""
        var letterBits = [String]()
        
        if let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelData = try? String(contentsOf: levelURL) {
                var lines = levelData.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    clueString += "\(index + 1) \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionsString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
            }
        }
        
        DispatchQueue.main.async {
            self.cluesLabel.text = solutionsString.trimmingCharacters(in: .whitespacesAndNewlines)
            self.answersLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            letterBits.shuffle()
            
            if letterBits.count == self.letterButtons.count {
                for i in 0..<self.letterButtons.count {
                    self.letterButtons[i].setTitle(letterBits[i], for: .normal)
                }
            }
        }
    }
    
    func levelUp (_ action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
       
        for button in letterButtons {
            animateButtons(button: button, buttonAlpha: 1, buttonsArrayAction: nil)
        }
        
        loadLevel()
    }
    
    func animateButtons(button: UIButton, buttonAlpha: CGFloat, buttonsArrayAction: String?) {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [],
                       animations: {
                            button.alpha = buttonAlpha
                        },
                       completion: { _ in
                            if buttonsArrayAction == "append" {
                                self.activatedButtons.append(button)
                            } else {
                                return
                            }
                        })
    }
    
}

