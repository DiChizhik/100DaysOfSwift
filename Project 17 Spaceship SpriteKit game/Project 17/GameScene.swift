//
//  GameScene.swift
//  Project 17
//
//  Created by Diana Chizhik on 08/06/2022.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private lazy var starfield: SKEmitterNode = {
       let starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        return starfield
    }()
    
    private lazy var player: SKSpriteNode = {
       let player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        return player
    }()
    
    private lazy var scoreLabel: SKLabelNode = {
       let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Score: 0"
        label.position = CGPoint(x: 16, y: 16)
        label.horizontalAlignmentMode = .left
        return label
    }()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var spaceDebris = ["ball", "tv", "hammer"]
    
    var timer: Timer?
    
    var isGameOver = false
    
    var isPlayerTouched = false
    
    var numberOfEnemies = 0
    var timeInterval = 1.0
    var reductionIncrement = 0.1
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        addChild(starfield)
        addChild(player)
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: [], repeats: true)
       
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    @objc func createEnemy() {
        guard isGameOver == false else { return }
        guard let enemy = spaceDebris.randomElement() else { return }
            
        let enemySprite = SKSpriteNode(imageNamed: enemy)
        addChild(enemySprite)
            
        enemySprite.position = CGPoint(x: 1300, y: Int.random(in: 50...730))
        enemySprite.physicsBody = SKPhysicsBody(texture: enemySprite.texture!, size: enemySprite.size)
        enemySprite.physicsBody?.contactTestBitMask = 1
        enemySprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemySprite.physicsBody?.angularVelocity = 5
        enemySprite.physicsBody?.linearDamping = 0
        enemySprite.physicsBody?.angularDamping = 0
            
        numberOfEnemies += 1
        
        if numberOfEnemies == 10 {
            timer?.invalidate()
            numberOfEnemies = 0
            timeInterval -= reductionIncrement
            
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: [], repeats: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if node == player {
                player.position = location
                isPlayerTouched = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerTouched == true else {return}
        guard let touch = touches.first else { return }
        
        var location = touch.location(in: self)
        
        if location.x < 100 {
            location.x = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPlayerTouched = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
    }
    
}
