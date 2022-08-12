//
//  GameScene.swift
//  Project 14 whack-a-penquin
//
//  Created by Diana Chizhik on 31/05/2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var background: SKSpriteNode = {
       let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        return background
    }()
    
    var gameScore: SKLabelNode = {
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 48
        scoreLabel.position = CGPoint(x: 8, y: 8)
        scoreLabel.horizontalAlignmentMode = .left
        return scoreLabel
    }()
    
    var gameOver: SKSpriteNode = {
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        return gameOver
    }()
    
    var finalScoreLabel: SKLabelNode = {
        let finalScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        finalScoreLabel.fontSize = 48
        finalScoreLabel.position = CGPoint(x: 512, y: 284)
        finalScoreLabel.zPosition = 1
        return finalScoreLabel
    }()
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
            finalScoreLabel.text = "Earned \(score) points!"
        }
    }
    var numberOfRounds = 0
   
    var slots = [WhackSlot]()
    var popupTime = 0.85
    
    override func didMove(to view: SKView) {
        addChild(background)
        addChild(gameScore)
       
        for i in 0..<5 { createSlots(at: CGPoint(x: 100 + (i * 170), y: 410))}
        for i in 0..<4 { createSlots(at: CGPoint(x: 180 + (i * 170), y: 320))}
        for i in 0..<5 { createSlots(at: CGPoint(x: 100 + (i * 170), y: 230))}
        for i in 0..<4 { createSlots(at: CGPoint(x: 180 + (i * 170), y: 140))}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else {continue}
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                score += 1
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
                if let smoke = SKEmitterNode(fileNamed: "smokeParticles") {
                    smoke.position = location
                    addChild(smoke)
                }
            }
        }
    }
    
    func createSlots(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numberOfRounds += 1
        if numberOfRounds >= 30 {
            for slot in slots{
                slot.hide()
            }
        
            addChild(gameOver)
            addChild(finalScoreLabel)
            run(SKAction.playSoundFileNamed("gameOver.m4a", waitForCompletion: true))
            
            return
        }
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 1...12) > 4 { slots[1].show(hideTime: popupTime)}
        if Int.random(in: 1...12) > 8 { slots[2].show(hideTime: popupTime)}
        if Int.random(in: 1...12) > 10 { slots[3].show(hideTime: popupTime)}
        if Int.random(in: 1...12) > 11 { slots[4].show(hideTime: popupTime)}
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2.0
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
        
        DispatchQueue.main.asyncAfter(deadline: <#T##DispatchTime#>, execute: <#T##() -> Void#>)
    }
}
