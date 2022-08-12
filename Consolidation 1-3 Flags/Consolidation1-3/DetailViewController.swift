//
//  DetailViewController.swift
//  Consolidation1-3
//
//  Created by Diana Chizhik on 11/05/2022.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var button: UIButton!
    var selectedImage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedImage!.uppercased()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector (actionTapped))

        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    @objc func actionTapped() {
        guard let image = imageView.image?.jpegData(compressionQuality: 1.0)
        else {
            print("No image found")
            return
            }
        
        let ac = UIActivityViewController(activityItems: [image, "\(selectedImage!.uppercased())"], applicationActivities: [])
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
        
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Flag History", message: "No information available", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel, handler: {(action) in self.dismiss(animated: true)}))
    present(alertController, animated: true)
    }
}
