//
//  ViewController.swift
//  Project 15
//
//  Created by Diana Chizhik on 05/06/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var tapButton: UIButton!
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        return imageView
    }()
    
    private var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.addSubview(imageView)
    }

    @IBAction func tapped(_ sender: UIButton) {
        sender.isHidden = true
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5,
                       options: [],
                       animations: {
                            switch self.currentAnimation {
                            case 0:
                                self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                            case 1:
                                self.imageView.transform = .identity
                            case 2:
                                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
                            case 3:
                                self.imageView.transform = .identity
                            case 4:
                                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                            case 5:
                                self.imageView.transform = .identity
                            case 6:
                                self.imageView.alpha = 0.1
                                self.imageView.backgroundColor = .gray
                            case 7:
                                self.imageView.alpha = 1
                                self.imageView.backgroundColor = .clear
                            default:
                                break
                            }
                        },
                       completion: { finished in
                            sender.isHidden = false
                        })

        currentAnimation += 1
        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
    
}

