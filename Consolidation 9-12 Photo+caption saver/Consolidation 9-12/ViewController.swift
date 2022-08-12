//
//  ViewController.swift
//  Consolidation 9-12
//
//  Created by Diana Chizhik on 28/05/2022.
//

import UIKit

class DetailViewController: UIViewController {
    private var imageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.frame = CGRect(x: 0, y: 100, width: 300, height: 300)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    
    var selectedImage: Picture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
        
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let path = Files.getDocumentDirectory().appendingPathComponent(selectedImage?.name ?? "")
        imageView.image = UIImage(contentsOfFile: path.path)
    }
    
    @objc private func shareImage() {
        guard let imageToShare = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No images found")
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [imageToShare, selectedImage!.caption], applicationActivities: [])
        present(activityController, animated:true)
    }
}
