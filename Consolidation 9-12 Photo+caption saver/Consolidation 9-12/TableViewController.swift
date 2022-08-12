//
//  TableViewController.swift
//  Consolidation 9-12
//
//  Created by Diana Chizhik on 28/05/2022.
//

import UIKit

class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var pictures = [Picture]()
    var selectedPicture = Picture(name: "noName", caption: "noCaption")
    var selection = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Files.loadSavedData(to: &pictures, forKey: "pictures")
        
        tableView.register(CaptionTableViewCell.self, forCellReuseIdentifier: CaptionTableViewCell.reuseIdentifier)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(takePicture))
    }
    
    @objc func takePicture() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        
        let imageName = UUID().uuidString
        let imagePath = Files.getDocumentDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let picture = Picture(name: imageName, caption: "Add caption")
        pictures.append(picture)
        Files.save(property: pictures, forKey: "pictures")
        tableView.reloadData()
        
        dismiss(animated: true)
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CaptionTableViewCell.reuseIdentifier, for: indexPath) as? CaptionTableViewCell else { return UITableViewCell() }
        
        let picture = pictures[indexPath.row]
        cell.configure(caption: picture.caption)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPicture = pictures[indexPath.row]
        selection = indexPath.row
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Change caption", style: .default, handler: changeCaption))
        ac.addAction(UIAlertAction(title: "View image", style: .default, handler: viewImage))
        present(ac, animated: true)
    }
    
   func changeCaption(action: UIAlertAction) {
       let ac = UIAlertController(title: "New caption", message: nil, preferredStyle: .alert)
       ac.addTextField()
       ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak ac, weak self] _ in
           if let newCaption = ac?.textFields?[0].text {
               self?.selectedPicture.caption = newCaption
               self?.pictures.remove(at: self!.selection)
               self?.pictures.insert(self!.selectedPicture, at: self!.selection)
               Files.save(property: self!.pictures, forKey: "pictures")
               self?.tableView.reloadData()
           }
       })
       ac.addAction(UIAlertAction(title: "Cancel", style: .default))
       present(ac, animated: true)
    }
               
    func viewImage(action: UIAlertAction) {
        let detailViewController = DetailViewController()
        detailViewController.selectedImage = selectedPicture
        navigationController?.pushViewController(detailViewController, animated: true)
    }
                     
}
