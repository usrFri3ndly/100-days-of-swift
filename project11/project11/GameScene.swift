//
//  GameScene.swift
//  project11
//
//  Created by Sc0tt on 13/10/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // ball array
    let ballColours = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    
    // score
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // editing mode
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }

    override func didMove(to view: SKView) {
        // add background in center
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        // ignore transparencies [alpha]
        background.blendMode = .replace
        // position behind all other assets
        background.zPosition = -1
        addChild(background)
        
        // add and position score label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        // add and position edit label
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        // current scene is contact delegate
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // read first touch and look for location
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // checkwhat node exists at this location
        let objects = nodes(at: location)
        
        // if edit label was tapped
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            // if label was not tapped
            if editingMode {
                // create random size
                let size = CGSize(width: Int.random(in: 16...120), height: 16)
                // create new box with random size assigned
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                // rotate the box and place where tapped
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                // static box
                box.physicsBody?.isDynamic = false
                addChild(box)
            } else {
                // create bouncy ball with random colour in touch location
                let ball = SKSpriteNode(imageNamed: ballColours.randomElement()!)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                // restitution = bouncyness
                ball.physicsBody?.restitution = 0.4
                // bounce off everything that has a physics body and detect collisions
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = location
                ball.name = "ball"
                addChild(ball)
            }
        }
        
        /* place box in touch location
        let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        box.position = location
        addChild(box) */
    }
    
    // add bouncer in specified position
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        // do not allow the bouncer to move
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    // load good and bad slots
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        
        // create physics body for slotBase
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        // make slot glows spin continuously
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    // check if collision of ball is with good or bad slot
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    // remove node from node tree
    func destroy(ball: SKNode) {
        // load effect and place in location of ball
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // guard statement check to see if object still exists before continuing
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        // if bodyA is ball, other object is bodyB
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
            // if bodyB is ball, other object is bodyA
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
            
        /* if bodyA is ball, other object is bodyB
        if contact.bodyA.node?.name == "ball" {
            collision(between: contact.bodyA.node!, object: contact.bodyB.node!)
        // if bodyB is ball, other object is bodyB
        } else if contact.bodyB.node?.name == "ball" {
            collision(between: contact.bodyB.node!, object: contact.bodyA.node!) */
        }
    }
}
