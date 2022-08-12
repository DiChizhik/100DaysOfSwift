//
//  GameScene.swift
//  Project 26 gameWithAccelerometer
//
//  Created by Diana Chizhik on 29/06/2022.
//
import CoreMotion
import SpriteKit

class GameScene: SKScene {
    enum CategoryBitMask: UInt32 {
        case player = 1
        case wall = 2
        case star = 4
        case vortex = 8
        case finish = 16
    }
    
    enum PhysicsBodyShape {
        case circle, rect
    }
    
    var player: SKSpriteNode!
    var levelNodes = [SKNode]()
    var lastTouchPosition: CGPoint?
    
    var motionManager: CMMotionManager?
    
    var level = 1
    private lazy var scoreLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.position = CGPoint(x: 16, y: 16)
        label.zPosition = 2
        label.text = "Score: 0"
        label.horizontalAlignmentMode = .left
        return label
    }()
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var isGameOver = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        addChild(scoreLabel)
        
        loadLevel()
        createPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
    #if targetEnvironment(simulator)
        if let currentTouch = lastTouchPosition {
            let difference = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: difference.x / 100, dy: difference.y / 100)
        }
    #else
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    #endif
    }
        
    private func loadLevel() {
        let lines = loadLevelData()
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (column * 64) + 32, y: (row * 64) + 32)
                
                if letter == "x" {
                    configureNode(imageName: "block", physicsBodyShape: .rect, action: nil, categoryBitMask: .wall, contactTestBitMask: nil, collisionBitMask: nil, position: position)

                } else if letter == "v" {
                    let action = SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1))
                    configureNode(imageName: "vortex", physicsBodyShape: .circle , action: action, categoryBitMask: .vortex, contactTestBitMask: .player, collisionBitMask: 0, position: position)
            
                } else if letter == "s" {
                    configureNode(imageName: "star", physicsBodyShape: .circle, action: nil, categoryBitMask: .star, contactTestBitMask: .player, collisionBitMask: 0, position: position)
                } else if letter == "f" {
                    configureNode(imageName: "finish", physicsBodyShape: .circle, action: nil, categoryBitMask: .finish, contactTestBitMask: .player, collisionBitMask: 0, position: position)
                } else if letter == " " {
                    
                } else {
                    fatalError("Unknown letter \(letter)")
                }
            }
        }
    }
    
    private func loadLevelData()-> [String] {
        guard let level = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else { fatalError("Couldn't find the file")
        }
        guard let levelString = try? String(contentsOf: level).trimmingCharacters(in: .whitespacesAndNewlines) else {
            fatalError("Couldn't load the level")
        }
        
        let lines = levelString.components(separatedBy: "\n")
        return lines
    }
    
    private func configureNode(imageName: String, physicsBodyShape: PhysicsBodyShape, action: SKAction?, categoryBitMask: CategoryBitMask, contactTestBitMask: CategoryBitMask?, collisionBitMask: UInt32?, position: CGPoint) {
        let node = SKSpriteNode(imageNamed: imageName)
        node.name = imageName
        node.position = position
        
        if let action = action {
            node.run(action)
        }
        
        if physicsBodyShape == PhysicsBodyShape.circle {
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        } else if physicsBodyShape == PhysicsBodyShape.rect {
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        }
        
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = categoryBitMask.rawValue
        
        if let collisionBitMask = collisionBitMask {
            node.physicsBody?.collisionBitMask = collisionBitMask
        }
        
        if let contactTestBitMask = contactTestBitMask {
            node.physicsBody?.contactTestBitMask = contactTestBitMask.rawValue
        }
        
        addChild(node)
        levelNodes.append(node)
    }
    
    private func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
//        player.position = CGPoint(x: 96, y: 672)
        player.position = CGPoint(x: 928, y: 96)
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CategoryBitMask.player.rawValue
        player.physicsBody?.contactTestBitMask = CategoryBitMask.star.rawValue | CategoryBitMask.vortex.rawValue | CategoryBitMask.finish.rawValue
        player.physicsBody?.collisionBitMask = CategoryBitMask.wall.rawValue
        addChild(player)
        levelNodes.append(player)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    private func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            isGameOver = true
            player.physicsBody?.isDynamic = false
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            isGameOver = true
            player.physicsBody?.isDynamic = false
            
            player.removeFromParent()
            if let emitter = SKEmitterNode(fileNamed: "fireworks") {
                emitter.position = CGPoint(x: node.position.x, y: node.position.y + 32)
                emitter.zPosition = 1
                addChild(emitter)
                levelNodes.append(emitter)
                
                emitter.run(SKAction.wait(forDuration: 2.5)) {
                    for node in self.levelNodes {
                        node.removeFromParent()
                    }
                    self.level += 1
                    self.loadLevel()
                    self.createPlayer()
                    self.isGameOver = false
                }
            }
        }
    }
}
