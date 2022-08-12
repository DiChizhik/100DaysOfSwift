//
//  GameScene.swift
//  Project 20
//
//  Created by Diana Chizhik on 14/06/2022.
//

import SpriteKit


class GameScene: SKScene {
    var gameTimer: Timer?
    
    var fireworks = [SKNode]()
    
    let bottomEdge = -22
    let leftEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var numLaunches = 0
    private var maxNumLaunches = 10
    
    private lazy var scoreLabel: SKLabelNode = {
       let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Score: 0"
        label.horizontalAlignmentMode = .left
        return label
    }()
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        addChild(scoreLabel)
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = "firework"
        firework.colorBlendFactor = 1
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .red
        case 1:
            firework.color = .green
        case 2:
            firework.color = .cyan
        default:
            break
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        fireworks.append(node)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        guard numLaunches < maxNumLaunches  else {
            gameTimer?.invalidate()
            return
        }
        
        numLaunches += 1
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 1:
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 2:
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                assert(!fireworks.isEmpty, "Fireworks is empty")
                assert(!parent.children.isEmpty, "Firework node array is empty")
    
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                print("Found a mismatch")
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    private func explode(firework: SKNode) {
        var emitterNode = SKEmitterNode()
        
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitterNode = emitter
            emitter.position = firework.position
            addChild(emitter)
        }
        firework.removeFromParent()
        
        let duration = (CGFloat(emitterNode.numParticlesToEmit) / emitterNode.particleBirthRate) + emitterNode.particleLifetime
        let delay = SKAction.wait(forDuration: duration)
        emitterNode.run(delay) {
            emitterNode.removeFromParent()
        }
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, parent) in fireworks.enumerated().reversed() {
            guard let firework = parent.children.first as? SKSpriteNode else { continue }
            if firework.name == "selected" {
                    explode(firework: parent)
                    fireworks.remove(at: index)
                    numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 400
        }
    }
}
