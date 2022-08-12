//
//  ViewController.swift
//  Project 38 CoreData
//
//  Created by Diana Chizhik on 12/07/2022.
//
import CoreData
import UIKit

class ViewController: UITableViewController {
    var container: NSPersistentContainer!
    var commitPredicate: NSPredicate?
    var fetchedResultsController: NSFetchedResultsController<Commit>!
    
    override func loadView() {
        super.loadView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = NSPersistentContainer(name: "Project38")
        container.loadPersistentStores {storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
            
        performSelector(inBackground: #selector(fetchCommits), with: nil)

        loadSavedData()
    }
    
    @objc func fetchCommits() {
        let newestCommitDate = getNewestCommitDate()
        print(newestCommitDate)
        
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) {
            let jsonCommits = JSON(parseJSON: data)
            let jsonCommitArray = jsonCommits.arrayValue
            print(jsonCommitArray.count)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                for jsonCommit in jsonCommitArray{
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJson: jsonCommit)
                }
                
                self.saveContext()
                self.saveNewestDate()
                self.loadSavedData()
            }

        }
    }
    
    func getNewestCommitDate()-> String {
        let dateFormatter = ISO8601DateFormatter()
        
        let userDefaults = UserDefaults.standard
        if let savedDate = userDefaults.object(forKey: "newest") as? Date {
            return dateFormatter.string(from: savedDate)
        }
        
        return dateFormatter.string(from: Date(timeIntervalSince1970: 0))
    }
    
    func saveNewestDate() {
        let userDefaults = UserDefaults.standard
        guard userDefaults.object(forKey: "newest") == nil else { return }
        
        let newest = Commit.createFetchRequest()
        newest.predicate = nil
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1
        
        if let newestCommits = try? container.viewContext.fetch(newest) {
            if newestCommits.count > 0 {
                let newestCommit = newestCommits[0]
                userDefaults.set(newestCommit.date.addingTimeInterval(1), forKey: "newest")
            }
        }
    }

    func configure(commit: Commit, usingJson json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        
        var commitAuthor: Author!
        
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                commitAuthor = authors[0]
            }
        }
        
        if commitAuthor == nil {
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        
        commit.author = commitAuthor
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error while saving: \(error)")
            }
        }
    }
    
    func loadSavedData() {
        if fetchedResultsController == nil {
            let request = Commit.createFetchRequest()
            let sort = NSSortDescriptor(key: "author.name", ascending: true)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name" , cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        fetchedResultsController.fetchRequest.predicate = commitPredicate
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Show fixes only", style: .default) { [weak self] _ in
            self?.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self?.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Ignore PRs", style: .default) { [weak self] _ in
            self?.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self?.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Show most recent", style: .default) { [weak self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self?.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self?.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Show only GitHub commits", style: .default) { [weak self] _ in
            self?.commitPredicate = NSPredicate(format: "author.name == 'GitHub'")
            self?.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [weak self] _ in
            self?.commitPredicate = nil
            self?.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
}

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        let commit = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = commit.message
        cell.detailTextLabel?.text = "By \(commit.author.name) on \(commit.date.description)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        Opens a detailViewController with commit.message
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController {
//            vc.detailItem = fetchedResultsController.object(at: indexPath)
//            navigationController?.pushViewController(vc, animated: true)
//        }
        
//      Opens commit.url in a webView
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailWV") as? DetailWebViewViewController {
            let item = fetchedResultsController.object(at: indexPath)
            vc.urlString = item.url
            print(item.url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(commit)
            saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
}


