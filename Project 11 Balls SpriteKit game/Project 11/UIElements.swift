//
//  UIElements.swift
//  Project 11
//
//  Created by Diana Chizhik on 26/05/2022.
//

import Foundation
import SpriteKit

struct UIElements {
    private var balls = [SKSpriteNode]()
    fileprivate var ballsNames = ["ballRed", "ballYellow", "ballCyan", "ballPurple", "ballGreen", "ballBlue", "ballGrey"]
    
    mutating func generateRandomBall()-> SKSpriteNode {
        for name in ballsNames {
            let ball = SKSpriteNode(imageNamed: name)
            ball.name = "ball"
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
            ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
            ball.physicsBody?.restitution = 0.4
            
            balls.append(ball)
        }
        let randomBall = balls[Int.random(in: 0..<balls.count)]
        
        return randomBall
    }
    
    func addBouncer(at position: CGPoint) -> SKSpriteNode {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        bouncer.position = position
        
        return bouncer
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) -> [SKSpriteNode] {
        let slotBase: SKSpriteNode
        let slotGlow: SKSpriteNode
        if isGood == true {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotBase.name = "good"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotBase.name = "bad"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
        return [slotBase, slotGlow]
    }
    
    func createBox()-> SKSpriteNode {
        let size = CGSize(width: Int.random(in: 16...128), height: 16)
        let color = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        let box = SKSpriteNode(color: color, size: size)
        box.name = "box"
        box.zRotation = CGFloat.random(in: 0...3)
        
        box.physicsBody = SKPhysicsBody(rectangleOf: size)
        box.physicsBody?.isDynamic = false
        
        return box
    }
    
}
