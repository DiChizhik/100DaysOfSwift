//
//  TableViewCell.swift
//  Consolidation 13-15
//
//  Created by Diana Chizhik on 12/06/2022.
//

import Foundation
import UIKit

final class TableViewCell: UITableViewCell {
    static var identifier: String{NSStringFromClass(self)}
    
    private lazy var indexLabel: UILabel = {
      let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = UIColor.gray
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
      let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = UIColor.black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        
        stackView.addArrangedSubview(indexLabel)
        stackView.addArrangedSubview(bodyLabel)
        stackView.spacing = 6
        
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(index: String, body: String) {
        indexLabel.text = index
        bodyLabel.text = body
    }
    
}

