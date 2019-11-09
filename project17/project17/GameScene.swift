//
//  GameScene.swift
//  project17
//
//  Created by Sc0tt on 05/11/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        // background
        backgroundColor = .black
        starfield = SKEmitterNode(fileNamed: "starfield")
        // enter from middle right of screen
        starfield.position = CGPoint(x: 1024, y: 384)
        // show 10 seconds of simulation when game launches
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        // create player sprite
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        // create physics body from image texture
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        
        // score label in bottom left of screen
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // create timer for enemy creation that repeats 3 times per second
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        // attempt to assign a random enemy
        guard let enemy = possibleEnemies.randomElement() else { return }
        // create enemy to the far right of scene at a random height
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint (x: 1200, y: Int.random(in:50...736))
        addChild(sprite)
        
        // create physics body from texture
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        // allow collision with player
        sprite.physicsBody?.categoryBitMask = 1
        // push sprite to left
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        // make sprite spin
        sprite.physicsBody?.angularVelocity = 5
        // stop spinning from slowing down
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
    }

    override func update(_ currentTime: TimeInterval) {
        
        // remove nodes from scene when they disappear off screen
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        // clamp player so they can only move between set coordinates
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    // game over if player removes finger from screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Finger Lifted!")
        
        if !isGameOver {
            gameOver()
        }
        
    }
    
    // end game when contact between player and enemy
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        gameOver()
    }
    
    func gameOver() {
        
        isGameOver = true
        player.removeFromParent()
        
        // shower game over label
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 46
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.horizontalAlignmentMode = .center
        addChild(gameOverLabel)
        
        // stop enemies from spawning
        gameTimer?.invalidate()
        gameTimer = nil
    }
}
