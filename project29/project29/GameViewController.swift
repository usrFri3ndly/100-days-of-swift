//
//  GameViewController.swift
//  project29
//
//  Created by Sc0tt on 04/01/2020.
//  Copyright © 2020 Sc0tt. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    
    @IBOutlet var p1ScoreLabel: UILabel!
    @IBOutlet var p2ScoreLabel: UILabel!
    
    @IBOutlet var windLabel: UILabel!
    
    var windTimer: Timer?
    var currentWindSpeed: CGFloat!
    
    var p1Score: Int = 0 {
         didSet {
             p1ScoreLabel.text = "\(p1Score)"
         }
     }
     
    var p2Score: Int = 0 {
         didSet {
             p2ScoreLabel.text = "\(p2Score)"
         }
     }
    
    var currentGame: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        p1Score = 0
        p2Score = 0
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                // allow direct access to GameScene
                currentGame = scene as? GameScene
                currentGame?.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        // default values for sliders
        angleChanged(self)
        velocityChanged(self)
        
        // set initial wind value
        wind()
        
        // change wind direction every 15 seconds
        windTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(wind), userInfo: nil, repeats: true)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func angleChanged(_ sender: Any) {
        // convert float of slider to int
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: Any) {
        // hide interface when launch button is pressed
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        launchButton.isHidden = true
        
        // pass players values to gameScene
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        // show interface
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        launchButton.isHidden = false
    }
    
    @objc func wind() {
        
        // get random horizontal gravity
        currentWindSpeed = CGFloat.random(in: -6...6)
        currentGame?.physicsWorld.gravity = CGVector(dx: currentWindSpeed, dy: -9.8)
        
        // change label state based on strength of wind
        if currentWindSpeed <= -3 {
            windLabel.text = "<<< WIND"
        } else if currentWindSpeed < 0 {
            windLabel.text = "<< WIND"
        } else if currentWindSpeed >= 3 {
           windLabel.text = "WIND >>>"
        } else if currentWindSpeed > 0 {
            windLabel.text = "WIND >>"
        }
    }
    
}
