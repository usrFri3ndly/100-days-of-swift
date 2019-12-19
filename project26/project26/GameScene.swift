//
//  GameScene.swift
//  project26
//
//  Created by Sc0tt on 10/12/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import CoreMotion
import SpriteKit

// numbers double so that they can be combined without colliding with existing values
enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    // touch hack for simulator
    var lastTouchPosition: CGPoint?
    
    var motionManager: CMMotionManager?
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
    var levelEndLabel: SKLabelNode!
    var nextLevelLabel: SKLabelNode!
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var currentLevel = 1
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        loadLevel()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // start collecting accelerometer data
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
    }
    
    func loadLevel() {
        // load string from text file
        guard let levelURL = Bundle.main.url(forResource: "level\(currentLevel)", withExtension: "txt") else {
            fatalError("File not found.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Unable to load file.")
        }
        
        // seperate string into lines
        let lines = levelString.components(separatedBy: "\n")
        
        // loop over lines from string to create rows
        for (row, line) in lines.reversed().enumerated() {
            // create columns
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                // create game assets at positions
                
                if letter == "x" {
                    // wall
                    createWall(at: position)
                } else if letter == "v" {
                    // vortex
                    createVortex(at: position)
                } else if letter == "s" {
                    // star
                    createStar(at: position)
                } else if letter == "f" {
                    // finish
                    createFinish(at: position)
                } else if letter == " " {
                    // this is an empty space - do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
        
        createPlayer()
    }

    func createWall(at position: CGPoint ) {
        let node = SKSpriteNode(imageNamed: "block")
        node.name = "block"
        node.position = position
    
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                // ensure raw value is passed
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    func createVortex(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        
        // make vortex spin
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        // ensure vortext doesn't move around
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        // tell us when vortex touches player
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.contactTestBitMask = 0
        addChild(node)
    }
    
    func createStar(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createFinish(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        // combine numbers
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
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
        // stop player control if isGameOver true
        guard isGameOver == false else { return }
        
        // code will only run in the simulator
        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            // divide by 100 to scale down movement
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        // physical device code
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            // coordinates reversed
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            // stop player from moving
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            // ball gets sucked into vortex
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            // sequence array
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                // create new player after sequence
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // levelEnd
            node.removeFromParent()
            player.removeFromParent()
            currentLevel += 1
            
            levelEnd()
            
        }
    }
    
    func levelEnd() {
        
        levelEndLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        levelEndLabel.text = "Well Done!"
        levelEndLabel.fontSize = 46
        levelEndLabel.fontColor = .green
        levelEndLabel.position = CGPoint(x: 512, y: 384)
        levelEndLabel.zPosition = 2
        levelEndLabel.horizontalAlignmentMode = .center
        addChild(levelEndLabel)
        
        nextLevelLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        nextLevelLabel.text = "Get Ready for the next level..."
        nextLevelLabel.fontSize = 36
        nextLevelLabel.position = CGPoint(x: 512, y: 324)
        nextLevelLabel.zPosition = 2
        nextLevelLabel.horizontalAlignmentMode = .center
        addChild(nextLevelLabel)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
            self.removeChildren()
            self.loadLevel()
        }
    }
    
    // remove assets to continue to next level
    func removeChildren() {
        for node in self.children {
                if node.name == "block" {
                    node.removeFromParent()
                } else if node.name == "vortex" {
                    node.removeFromParent()
                } else if node.name == "star" {
                    node.removeFromParent()
                } else if node.name == "finish" {
                    node.removeFromParent()
                }
            
            nextLevelLabel.removeFromParent()
            levelEndLabel.removeFromParent()
        }
    }
}
