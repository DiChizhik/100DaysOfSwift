//
//  ViewController.swift
//  Consolidation 4-6
//
//  Created by Diana Chizhik on 17/05/2022.
//

import UIKit

class ViewController: UITableViewController {

    var shoppingList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Shopping List"
        
        let addBarButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        let shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareShoppingList))
        navigationItem.rightBarButtonItems = [shareBarButton, addBarButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(makeNewList))
    
    }
    
    @objc func addItem() {
        let ac = UIAlertController(title: "New item", message: "Add products to your shopping list", preferredStyle: UIAlertController.Style.alert)
        
        ac.addTextField()
        
        let submitItem = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) { [weak ac, weak self] _ in
            if let newItem = ac?.textFields?[0].text {
                self?.shoppingList.insert(newItem, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self?.tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }
        ac.addAction(submitItem)
        
        present(ac, animated: true)
    }
    
    @objc func makeNewList() {
        shoppingList.removeAll()
        tableView.reloadData()
    }
    
    @objc func shareShoppingList() {
        let listToShare = shoppingList.joined(separator: "\n")
        let ac = UIActivityViewController(activityItems: ["Shopping list", listToShare], applicationActivities: [])
    present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = shoppingList[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }

}

