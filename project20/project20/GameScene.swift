//
//  GameScene.swift
//  project20
//
//  Created by Sc0tt on 17/11/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    
    // edges of screen
    var leftEdge = -22
    var bottomEdge = -22
    var rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            // code here
        }
    }
    
    override func didMove(to view: SKView) {
      
        // create background for scene
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        // create looped game timer for fireworks
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)

    }
    
    func createFirework (xMovement: CGFloat, x: Int, y: Int) {
        // create firework container
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        // create firework
        let firework = SKSpriteNode(imageNamed: "rocket")
        // ensures colour is applied in full
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        // assign random firework colour
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        // draw path for firework to follow
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        
        node.run(move)
        
        guard let emitter = SKEmitterNode(fileNamed: "fuse") else { return }
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
    
        // add to fireworks array
        fireworks.append(node)
        addChild(node)
    }
    
    
    @objc func launchFireworks () {
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            // launch fireworks straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            // launch fireworks in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: +100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: +200, x: 512 + 200, y: bottomEdge)
        case 2:
            // launch fireworks left to right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            // launch fireworks right to left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        default:
            break
        }
    }
    
    // look for touches
    func checkTouches(_ touches: Set<UITouch>) {
        // check for touch
        guard let touch = touches.first else { return }
        
        // location of touch
        let location = touch.location(in: self)
        // return nodes at touch location
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            // exit loop if node is not firework
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                // look for parent node
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                // only allow selection of same colour fireworks
                // reset selection if different colour is selected
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            // turn firework white
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
    
    // remove fireworks that are not destroyed by user
    override func update(_ currentTime: TimeInterval) {
        // work backwards through array
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        // place explosion at firework position
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        // reverse loop over array
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            // look for first child [firework]
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            // explode selected fireworks
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        // determine score from number of fireworks exploded
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
            score += 4000
        }
    }
    
}
