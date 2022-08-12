//
//  ViewController.swift
//  Consolidation 19-21 notesApp
//
//  Created by Diana Chizhik on 17/06/2022.
//

import UIKit

class HomeViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 20)
        return tableView
    }()
    
    private var notes = [Note]()
    private var selectedNoteIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
       
        let createNewNoteButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewNote))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbarItems = [spacer, createNewNoteButton]
        navigationController?.isToolbarHidden = false
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        loadNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { self.navigationController?.navigationBar.sizeToFit() }
    }
    
    @objc func createNewNote() {
        let newNoteViewController = NewNoteViewController()
        newNoteViewController.delegate = self
        navigationController?.pushViewController(newNoteViewController, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            assertionFailure()
            return UITableViewCell()
        }
        
        let note = notes[indexPath.row]
        cell.configure(name: note.name, details: note.details)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNoteIndex = indexPath.row
        let note = notes[selectedNoteIndex!]
        
        let newNoteViewController = NewNoteViewController()
        newNoteViewController.noteToDisplay = note
        newNoteViewController.delegate = self
        
        navigationController?.pushViewController(newNoteViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController: NewNoteViewControllerDelegate {
    func didCreateNote(_ note: Note?) {
        guard let note = note else { return }
        notes.insert(note, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        saveNotes(notes)
    }
    
    func didUpdateNote(_ note: Note?) {
        if let noteToUpdate = note {
            notes.remove(at: selectedNoteIndex!)
            notes.insert(noteToUpdate, at: selectedNoteIndex!)
            tableView.reloadData()
        } else {
            notes.remove(at: selectedNoteIndex!)
            tableView.deleteRows(at: [IndexPath(row: selectedNoteIndex!, section: 0)], with: .automatic)
        }
    
        saveNotes(notes)
    }
    
    func deleteNote() {
        notes.remove(at: selectedNoteIndex!)
        tableView.deleteRows(at: [IndexPath(row: selectedNoteIndex!, section: 0)], with: .automatic)
    }
}

extension HomeViewController {
    func saveNotes(_ notes: [Note]) {
        let jsonEncoder = JSONEncoder()
        
        if let dataToSave = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(dataToSave, forKey: "notes")
        } else {
            print("Failed to save notes")
        }
    }
    
    func loadNotes() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedData)
            } catch {
                print("Failed to load notes")
            }
        }
    }
}
