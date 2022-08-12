//
//  ViewController.swift
//  Project 27 CoreGraphics
//
//  Created by Diana Chizhik on 30/06/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRect()
    }

    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1
        if currentDrawType > 7 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRect()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatingSquares()
        case 4:
            drawRotatingLines()
        case 5:
            drawTextAndImage()
        case 6:
            drawStar()
        case 7:
            drawText()
        default:
            break
        }
    }
    
    func drawRect() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            context.cgContext.setFillColor(UIColor.orange.cgColor)
            context.cgContext.setStrokeColor(UIColor.brown.cgColor)
            context.cgContext.setLineWidth(10)
            
            context.cgContext.addRect(rect)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            context.cgContext.setFillColor(UIColor.orange.cgColor)
            context.cgContext.setStrokeColor(UIColor.brown.cgColor)
            context.cgContext.setLineWidth(10)
            
            context.cgContext.addEllipse(in: rect)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0..<8 {
                for column in 0..<8 {
                    if (row + column) % 2 == 0 {
                        context.cgContext.fill(CGRect(x: column * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
            
        }
        
        imageView.image = image
    }
    
    func drawRotatingSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image{ context in
            context.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            for _ in 0 ..< rotations {
                context.cgContext.rotate(by: CGFloat(amount))
                context.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    func drawRotatingLines() {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
            
            let image = renderer.image{ context in
                context.cgContext.translateBy(x: 256, y: 256)
                
                var first = true
                var length: CGFloat = 256
                
                for _ in 0 ..< 256 {
                    context.cgContext.rotate(by: CGFloat.pi / 2)
                    
                    if first {
                        context.cgContext.move(to: CGPoint(x: length, y: 50))
                        first = false
                    } else {
                        context.cgContext.addLine(to: CGPoint(x: length, y: 50))
                    }
                    
                    length *= 0.99
                }
                
                context.cgContext.setStrokeColor(UIColor.black.cgColor)
                context.cgContext.strokePath()
            }
            
            imageView.image = image
    }
    
    func drawTextAndImage() {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
            
            let image = renderer.image{ context in
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributes: [NSAttributedString.Key : Any] = [
                    .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                    .paragraphStyle: paragraphStyle
                ]
                
                let string = "Тише, мыши, кот на крыше!"
                let attributedString = NSAttributedString(string: string, attributes: attributes)
                
                attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
                
                let mouse = UIImage(named: "mouse")
                mouse?.draw(at: CGPoint(x: 300, y: 150))
            }
            
            imageView.image = image
    }
    
    func drawStar() {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
            
            let image = renderer.image{ context in
                context.cgContext.translateBy(x: 256, y: 256)
                
                
                let length: CGFloat = 256
                
                context.cgContext.rotate(by: CGFloat.pi)
                context.cgContext.move(to: CGPoint(x: 0, y: length))
                
                for line in 1 ... 10 {
                    context.cgContext.rotate(by: CGFloat.pi / 5)
                    
                    if line % 2 != 0 {
                        context.cgContext.addLine(to: CGPoint(x: 0, y: length/2))
                    } else {
                        context.cgContext.addLine(to: CGPoint(x: 0, y: length))
                    }
                }
                
                context.cgContext.setFillColor(UIColor.yellow.cgColor)
                context.cgContext.setStrokeColor(UIColor.brown.cgColor)
                context.cgContext.drawPath(using: .fillStroke)
            }
            
            imageView.image = image
    }
    
    func drawText() {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
            
            let image = renderer.image{ context in
                context.cgContext.translateBy(x: 70, y: 170)
                context.cgContext.move(to: CGPoint(x: 0, y: 0))
                
                context.cgContext.addLine(to: CGPoint(x: 51, y: 0))
                context.cgContext.addLine(to: CGPoint(x: 51, y: 170))
                context.cgContext.addLine(to: CGPoint(x: 51, y: 0))
                context.cgContext.addLine(to: CGPoint(x: 102, y: 0))
                
                context.cgContext.addLine(to: CGPoint(x: 127, y: 170))
                context.cgContext.addLine(to: CGPoint(x: 152, y: 85))
                context.cgContext.addLine(to: CGPoint(x: 177, y: 170))
                context.cgContext.addLine(to: CGPoint(x: 202, y: 0))
                
                context.cgContext.move(to: CGPoint(x: 227, y: 0))
                context.cgContext.addLine(to: CGPoint(x: 227, y: 170))
                
                context.cgContext.move(to: CGPoint(x: 252, y: 170))
                context.cgContext.addLine(to: CGPoint(x: 252, y: 0))
                context.cgContext.addLine(to: CGPoint(x: 354, y: 170))
                context.cgContext.addLine(to: CGPoint(x: 354, y: 0))
                
                context.cgContext.setLineWidth(5)
                context.cgContext.setStrokeColor(UIColor.orange.cgColor)
                context.cgContext.strokePath()
                
            }
            
            imageView.image = image
    }
}

