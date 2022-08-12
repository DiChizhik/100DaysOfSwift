//
//  TableTableViewController.swift
//  Extension
//
//  Created by Diana Chizhik on 13/06/2022.
//

import UIKit

protocol ScriptsTableViewControllerDelegate: AnyObject {
    func didChooseScript(_ tableView: UITableView, _ script: Script)
}

final class TableViewCell: UITableViewCell {
    static var identifier: String {NSStringFromClass(self)}
}

final class ScriptsTableViewController: UITableViewController {
    weak var delegate: ScriptsTableViewControllerDelegate?
    let dataHandlingService = DataHandlingService()
    
    var scripts = [Script]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)

        if let scriptsToLoad = dataHandlingService.loadScriptsFromUserDefaults(withKey: "scripts") {
            scripts = scriptsToLoad
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scripts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier) as? TableViewCell else { return UITableViewCell()}
        let script = scripts[indexPath.row]
        
        cell.textLabel?.text = script.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedScript = scripts[indexPath.row]
        delegate?.didChooseScript(tableView, selectedScript)
        navigationController?.popViewController(animated: true)
    }
}
