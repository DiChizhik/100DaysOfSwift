//
//  ViewController.swift
//  Consolidation1-3
//
//  Created by Diana Chizhik on 11/05/2022.
//

import UIKit

class ViewController: UITableViewController {

    var flags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flags"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        flags += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flag", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(named: flags[indexPath.row])
        content.text = flags[indexPath.row].uppercased()
        content.imageProperties.maximumSize = CGSize(width:50, height: 25)
        cell.contentConfiguration = content
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = flags[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

