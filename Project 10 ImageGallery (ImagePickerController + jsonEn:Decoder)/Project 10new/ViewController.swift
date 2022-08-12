//
//  ViewController.swift
//  Project 10new
//
//  Created by Diana Chizhik on 23/05/2022.
//
import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]()
    
    override func loadView() {
        super.loadView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, error) in
                
                DispatchQueue.main.async {
                    if success {
                        self?.load()
                    } else {
                        self?.showError(title: "Authentication failed", message: "You couldn't be verified. Please try again.")
                    }
                }
            }
        } else {
            showError(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.")
        }
    }
    
    private func showError(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        if KeychainWrapper.standard.string(forKey: "password") == nil {
            ac.addAction(UIAlertAction(title: "Set password", style: .default, handler: setPassword))
        } else {
            ac.addAction(UIAlertAction(title: "Enter password", style: .default, handler: enterPassword))
        }
        
        present(ac, animated: true)
    }
    
    private func setPassword(_ action: UIAlertAction) {
        guard KeychainWrapper.standard.string(forKey: "password") == nil else { return }
        
        let ac = UIAlertController(title: "Set password", message: "Enter a password to access the app", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak ac, weak self] _ in
            guard let password = ac?.textFields?[0].text else { return }
            KeychainWrapper.standard.set(password, forKey: "password")
            
            self?.load()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        present(ac, animated: true)
    }
    
    private func enterPassword(_ action: UIAlertAction) {
        let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak self, weak ac] _ in
            guard let enteredPassword = ac?.textFields?[0].text else { return }
            guard let password = KeychainWrapper.standard.string(forKey: "password") else { return }
            
            if password == enteredPassword {
                self?.load()
            } else {
                self?.showError(title: "Wrong password", message: nil)
            }
        })
        present(ac, animated: true)
    }
    
    @objc private func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    private func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
            print("Successfully saved data.")
        } else {
            print("Failed to save data.")
        }
    }
    
    func load() {
        navigationItem.leftBarButtonItem?.isEnabled = true
        
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                people = try jsonDecoder.decode([Person].self, from: savedData)
            } catch {
                print("Failed to load data.")
            }
        }
        
        collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else { fatalError() }
        
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.cornerRadius = 3
        
        cell.layer.cornerRadius = 7
        cell.layer.borderColor = UIColor(white: 0.5, alpha: 1).cgColor
        cell.layer.borderWidth = 2
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var person = people[indexPath.item]
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { _ in
            let ac = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
            ac.addTextField()
            
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
                if let newName = ac?.textFields?[0].text {
                    person.name = newName
                    
                    self?.people.remove(at: indexPath.item)
                    self?.people.insert(person, at: indexPath.item)
                    
                    self?.save()
                    self?.collectionView.reloadData()
                }
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .default))
            self.present(ac, animated: true)
        })
        
        ac.addAction(UIAlertAction(title: "Delete", style: .default) { [weak self] _ in
            
            self?.people.remove(at: indexPath.item)
            self?.collectionView.deleteItems(at: [indexPath])
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        present(ac, animated: true)
    }
}

