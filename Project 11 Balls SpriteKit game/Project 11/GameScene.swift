//
//  GameScene.swift
//  Project 11
//
//  Created by Diana Chizhik on 26/05/2022.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var uiElements = UIElements()
    
    lazy var scoreLabel: SKLabelNode = {
        let scorelabel = SKLabelNode(fontNamed: "Chalkduster")
        scorelabel.text = "Score: 0"
        scorelabel.horizontalAlignmentMode = .right
        return scorelabel
    }()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    lazy var editLabel: SKLabelNode = {
       let editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Add obstacles"
        editLabel.horizontalAlignmentMode = .left
        return editLabel
    }()
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
                editLabel.position = CGPoint(x: 100, y: 700)
            } else {
                editLabel.text = "Add obstacles"
                editLabel.position = CGPoint(x: 265, y: 700)
            }
        }
    }
    
    var ballsLimit = 5
    var usedBalls = 0 {
        didSet {
            ballsLeftLabel.text = "Balls left: \(ballsLimit - usedBalls) / 5"
        }
    }
    
    lazy var ballsLeftLabel: SKLabelNode = {
       let ballsLeftLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLeftLabel.text = "Balls left: 5 / 5"
        editLabel.horizontalAlignmentMode = .right
        return ballsLeftLabel
    }()
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel.position = CGPoint(x: 265, y: 700)
        addChild(editLabel)
        
        ballsLeftLabel.position = CGPoint(x: 830, y: 650)
        addChild(ballsLeftLabel)
        
        physicsWorld.contactDelegate = self
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        addChild(uiElements.addBouncer(at: CGPoint(x: 0, y: 0)))
        addChild(uiElements.addBouncer(at: CGPoint(x: 256, y: 0)))
        addChild(uiElements.addBouncer(at: CGPoint(x: 512, y: 0)))
        addChild(uiElements.addBouncer(at: CGPoint(x: 768, y: 0)))
        addChild(uiElements.addBouncer(at: CGPoint(x: 1012, y: 0)))
        
        var slots = [SKSpriteNode]()
        slots += uiElements.makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        slots += uiElements.makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        slots += uiElements.makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        slots += uiElements.makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

        for slot in slots {
            addChild(slot)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard usedBalls != ballsLimit else { return }
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            if objects.contains(editLabel) {
                editingMode.toggle()
            } else {
                if editingMode {
                    let box = uiElements.createBox()
                    box.position = location
                   
                    addChild(box)
                } else {
                    let ball = uiElements.generateRandomBall()
                    ball.position = CGPoint(x: location.x, y: 724)
                    
                    addChild(ball)
                    
                    usedBalls += 1
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(item: ball)
            score += 1
            usedBalls -= 1
        } else if object.name == "bad" {
            destroy(item: ball)
            score -= 1
        } else if object.name == "box" {
            destroy(item: object)
        }
    }
    
    func destroy(item: SKNode) {
        if item.name == "ball" {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = item.position
                addChild(fireParticles)
            }
        }
            
        item.removeFromParent()
    }
}
