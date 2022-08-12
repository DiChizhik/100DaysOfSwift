//
//  TableViewCell.swift
//  Consolidation 9-12
//
//  Created by Diana Chizhik on 28/05/2022.
//

import UIKit

class CaptionTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CaptionTableViewCell"
    
    private lazy var captionLabel: UILabel = {
       let captionLabel = UILabel()
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.font = .preferredFont(forTextStyle: .body)
        return captionLabel
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
        self.accessoryType = .disclosureIndicator
        
        contentView.addSubview(captionLabel)
        
        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            captionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            captionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(caption: String) {
        captionLabel.text = caption
    }

}
