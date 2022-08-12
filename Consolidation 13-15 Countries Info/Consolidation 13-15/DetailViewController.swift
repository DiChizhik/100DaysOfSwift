//
//  DetailViewController.swift
//  Consolidation 13-15
//
//  Created by Diana Chizhik on 12/06/2022.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource {
    static var identifier: String{NSStringFromClass(self)}
    let transformDataService = TransformDataService()
    
    var selectedCountry: Country?
    
    private lazy var rows: [RowData] = makeViewData()
    
    private struct RowData {
        let title: String
        let content: String
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Country details"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func makeViewData() -> [RowData] {
        guard let selectedCountry = selectedCountry else { return [] }

        let population = transformDataService.makeLookLikeInt(floatLookingString: selectedCountry.pop2022)
        let density = transformDataService.makeLookLikeInt(floatLookingString: selectedCountry.Density)
        let area = Int(selectedCountry.area.rounded())
        
        return [
            RowData(title: "Country", content: selectedCountry.name),
            RowData(title: "Capital", content: selectedCountry.capital),
            RowData(title: "Population", content: population),
            RowData(title: "Area", content: String(area) + " km²"),
            RowData(title: "Population density", content: density + "/km²")
        ]
    }
    
    @objc func shareTapped() {
        guard let selectedCountry = selectedCountry else { return }

        let ac = UIActivityViewController(activityItems: [selectedCountry], applicationActivities: [])
        present(ac, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as? TableViewCell else { fatalError() }
        
        let row = rows[indexPath.row]
        cell.configure(index: row.title, body: row.content)
        
        return cell
    }
}
