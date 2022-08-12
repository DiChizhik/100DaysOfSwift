//
//  ViewController.swift
//  Project 12 instaFilter
//
//  Created by Diana Chizhik on 30/05/2022.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter! {
        didSet {
            changeFilterButton.setTitle(currentFilter.name, for: .normal)
        }
    }

    private var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .lightGray
        return backgroundView
    }()
    
    private var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        return imageView
    }()
    
    private var intensityLabel: UILabel = {
        let intensitylabel = UILabel()
        intensitylabel.translatesAutoresizingMaskIntoConstraints = false
        intensitylabel.text = "Intensity"
       return intensitylabel
    }()
    
    private var slider: UISlider = {
       let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        return slider
    }()
    
    private var changeFilterButton: UIButton = {
        let changeFilterButton = UIButton(type: .system)
        changeFilterButton.translatesAutoresizingMaskIntoConstraints = false
        changeFilterButton.setTitle("Change filter", for: .normal)
        return changeFilterButton
    }()
    
    private var saveButton: UIButton = {
        let saveButton = UIButton(type: .system)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        return saveButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "photoFilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importImage))
        
        view.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            backgroundView.widthAnchor.constraint(equalTo: backgroundView.heightAnchor, multiplier: 0.7),
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        backgroundView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10)
        ])
        
        view.addSubview(changeFilterButton)
        view.addSubview(saveButton)
        
        changeFilterButton.addTarget(self, action: #selector(changeFilter), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            changeFilterButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            changeFilterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            changeFilterButton.widthAnchor.constraint(equalToConstant: 120),
            changeFilterButton.heightAnchor.constraint(equalToConstant: 44),
                    
            saveButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            saveButton.bottomAnchor.constraint(equalTo: changeFilterButton.bottomAnchor),
            saveButton.heightAnchor.constraint(equalTo: changeFilterButton.heightAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        view.addSubview(intensityLabel)
        view.addSubview(slider)
        
        slider.addTarget(self, action: #selector(intensityChanged), for: .valueChanged)

        NSLayoutConstraint.activate([
            intensityLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            intensityLabel.bottomAnchor.constraint(equalTo: changeFilterButton.topAnchor, constant: -20),
            intensityLabel.heightAnchor.constraint(equalToConstant: 21),
            intensityLabel.widthAnchor.constraint(equalToConstant: 72),

            slider.centerYAnchor.constraint(equalTo: intensityLabel.centerYAnchor),
            slider.leadingAnchor.constraint(equalTo: intensityLabel.trailingAnchor, constant: 10),
            slider.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
    
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func importImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.alpha = 0
        guard let image = info[.editedImage] as? UIImage else {return}
        
        dismiss(animated: true)
        
        currentImage = image
        
        let inputImage = CIImage(image: currentImage)
        currentFilter.setValue(inputImage, forKey: kCIInputImageKey)
        
        applyProcessing()
        
        UIView.animate(withDuration: 2, delay: 0, options: [], animations: {self.imageView.alpha = 1}, completion: nil)
    }
    
    @objc func save(_ sender: UIButton) {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_: didFinishSavingWithError: contextInfo: )), nil)
        } else {
            let ac = UIAlertController(title: "No image found", message: "Pick an image first", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Back", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    @objc func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Change filter", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
    
    @objc func intensityChanged(_ sender: UISlider) {
        applyProcessing()
    }

    func setFilter(_ action: UIAlertAction) {
        guard currentImage != nil else { return }
        guard let actionTitle = action.title else {return}
        
        currentFilter = CIFilter(name: actionTitle)
        let inputImage = CIImage(image: currentImage)
        currentFilter.setValue(inputImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func applyProcessing() {
        guard let outputImage = currentFilter.outputImage else { return }
        
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(slider.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(slider.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(slider.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }

        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            imageView.image = uiImage
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Saving failed", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

