//
//  NewNoteViewController.swift
//  Consolidation 19-21 notesApp
//
//  Created by Diana Chizhik on 17/06/2022.
//

import UIKit

protocol NewNoteViewControllerDelegate: AnyObject {
    func didCreateNote(_ note: Note?)
    func didUpdateNote(_ note: Note?)
    func deleteNote()
}



class NewNoteViewController: UIViewController, UITextViewDelegate  {
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.delegate = self
        textView.text = {
            if let nameText = noteToDisplay?.name {
                if let detailsText = noteToDisplay?.details {
                    let text = "\(nameText)\n\(detailsText)"
                    return text
                } else {
                    let text = "\(nameText)"
                    return text
                }
            } else {
                return ""
            }
        }()
        return textView
    }()
    weak var delegate: NewNoteViewControllerDelegate?
    
    var noteToDisplay: Note?
    private var noteToSave: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if noteToDisplay != nil {
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
            navigationItem.leftBarButtonItem = backButton
            
            let deleteButton = UIButton()
            deleteButton.addTarget(self, action: #selector(deleteNoteTapped), for: .touchUpInside)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deleteButton)
        } else {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
            navigationItem.rightBarButtonItem = doneButton
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        noteToSave = Note(with: textView.text)
//    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func doneTapped() {
        noteToSave = Note(with: textView.text)
        delegate?.didCreateNote(noteToSave)
        navigationController?.popViewController(animated: true)
        }
    
    @objc func backTapped() {
        guard let noteToDisplay = noteToDisplay else { return }

        let noteToUpdate = Note(with: textView.text)
        if noteToDisplay.name == noteToUpdate?.name && noteToDisplay.details == noteToUpdate?.details {
            navigationController?.popViewController(animated: true)
            print("The notes are identical")
        } else {
            delegate?.didUpdateNote(noteToUpdate)
            navigationController?.popViewController(animated: true)
            print("The note was updated")
        }
    }
    
    @objc func deleteNoteTapped() {
        delegate?.deleteNote()
        navigationController?.popViewController(animated: true)
    }
    
//    func toggleRightButton() {
//        if navigationItem.rightBarButtonItem == nil {
//            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
//            navigationItem.rightBarButtonItem = doneButton
//        } else {
//            navigationItem.setRightBarButton(nil, animated: false)
//        }
//    }
//    
//    func toggleLeftButton() {
//        if navigationItem.leftBarButtonItem == nil {
//            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
//            navigationItem.leftBarButtonItem = backButton
//        } else {
//            navigationItem.setLeftBarButton(nil, animated: false)
//        }
//    }
}
