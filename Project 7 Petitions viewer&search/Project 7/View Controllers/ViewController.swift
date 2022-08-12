//
//  ViewController.swift
//  Project 7
//
//  Created by Diana Chizhik on 17/05/2022.
//

import UIKit

// NOTE: This file is not being used anymore, I copied its content to the classes
// MostRecentPetitionsViewController and TopRatedPetitionsViewController

class ViewController: UITableViewController {

    var petitions = [Petition]()
    var sortedPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(tappedCredits))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(tappedSearch))

        let urlString: String

        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parseData(data)
                return
            }
        }

        showError()
    }

    @objc func tappedCredits() {
        let ac = UIAlertController(title: "Credits", message: "The data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    @objc func tappedSearch() {
        let ac = UIAlertController(title: "Search for...", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let showSearchResults = UIAlertAction(title: "Search", style: .default) { [weak self, weak ac] _ in
            if let enteredText = ac?.textFields?[0].text {
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.search(for: enteredText)
                }
            }
        }
        let showAllPetitions = UIAlertAction(title: "See all", style: .default) { [weak self] _ in
            if let petitions = self?.petitions {
                self?.sortedPetitions = petitions
                self?.tableView.reloadData()
            }
        }
        ac.addAction(showSearchResults)
        ac.addAction(showAllPetitions)
        present(ac, animated: true)
    }

    func search(for text: String) {
        sortedPetitions.removeAll()
        for petition in petitions {
            if petition.title.contains(text) || petition.body.contains(text) {
                sortedPetitions.insert(petition, at: 0)
            }
        }

        DispatchQueue.main.async {
            if self.sortedPetitions.isEmpty {
                self.showSearchError()
            } else {
                self.tableView.reloadData()
            }
        }
    }

    func showError() {
        let ac = UIAlertController(title: "Error", message: "Data could not be loaded; check your connection or try again later.", preferredStyle: UIAlertController.Style.alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    func parseData (_ json: Data) {
        let decoder = JSONDecoder()

        if let petitionsData = try? decoder.decode(Petitions.self, from: json) {
            petitions = petitionsData.results
            sortedPetitions = petitions

            tableView.reloadData()
        }
    }

    func showSearchError() {
        let ac = UIAlertController(title: "No matches", message: "No matching petitions have been found", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedPetitions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        let petition = sortedPetitions[indexPath.row]
        content.text = petition.title
        content.textProperties.numberOfLines = 1
        content.secondaryText = petition.body
        content.secondaryTextProperties.numberOfLines = 1
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dvc = DetailViewController()
        dvc.detailItem = sortedPetitions[indexPath.row]
        navigationController?.pushViewController(dvc, animated: true)
    }
}

