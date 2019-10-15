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
    
    // balls remaining
    var ballsRemainingLabel: SKLabelNode!
    var ballsRemaining = 5 {
        didSet {
            ballsRemainingLabel.text = "Balls: \(ballsRemaining)"
        }
    }
    
    // number of boxes remaining
    var boxesRemaining = 0
    
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
    
    // game win/lose labels
    var gameLoseLabel: SKLabelNode!
    var gameWinLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        // add background in center
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        // ignore transparencies [alpha]
        background.blendMode = .replace
        // position behind all other assets
        background.zPosition = -1
        addChild(background)
        
        // add and position balls remaining label
        ballsRemainingLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsRemainingLabel.text = "Balls: 5"
        ballsRemainingLabel.horizontalAlignmentMode = .right
        ballsRemainingLabel.position = CGPoint(x: 980, y: 720)
        addChild(ballsRemainingLabel)
        
        // add and position edit label
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 720)
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
        let xLocation = touch.location(in:self).x
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
                box.name = "box"
                addChild(box)
                boxesRemaining += 1
                //print(boxesRemaining)
            } else {
                // create bouncy ball with random colour in touch location
                let ball = SKSpriteNode(imageNamed: ballColours.randomElement()!)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                // restitution = bouncyness
                ball.physicsBody?.restitution = 0.6
                // bounce off everything that has a physics body and detect collisions
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = CGPoint(x: xLocation, y: 750)
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
            ballsRemaining += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            ballsRemaining -= 1
        } else if object.name == "box" {
            //print("I just hit a box!")
            destroy(box: object)
        }
        
        // check if there are balls remaining
        if ballsRemaining == 0 {
            gameLose()
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
    
    // remove box from parent and check how many remain
    func destroy(box: SKNode) {
        box.removeFromParent()
        boxesRemaining -= 1
        
        // check if player has removed all boxes
        if boxesRemaining == 0
        {
            gameWin()
        }
    }
    
    // player looses
    func gameLose() {
        // print("You Lose. Continue?")
        gameLoseLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameLoseLabel.text = "YOU LOSE!"
        gameLoseLabel.fontSize = 56
        gameLoseLabel.fontColor = .red
        gameLoseLabel.horizontalAlignmentMode = .center
        gameLoseLabel.position = CGPoint(x: 512, y: 384)
        addChild(gameLoseLabel)
    }
    
    // player wins
    func gameWin()
    {
        // print("You Lose. Continue?")
        gameWinLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameWinLabel.text = "YOU WIN!"
        gameWinLabel.fontSize = 56
        gameWinLabel.fontColor = .green
        gameWinLabel.horizontalAlignmentMode = .center
        gameWinLabel.position = CGPoint(x: 512, y: 384)
        addChild(gameWinLabel)
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
