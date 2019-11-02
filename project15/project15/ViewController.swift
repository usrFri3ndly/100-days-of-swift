//
//  ViewController.swift
//  project15
//
//  Created by Sc0tt on 31/10/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imageView: UIImageView!
    var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create new imageView from asset
        imageView = UIImageView(image: UIImage(named: "penguin"))
        // position and add to subView
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
    }

    @IBAction func tapped(_ sender: UIButton) {
        // hide button when tapped
        sender.isHidden = true
        
        //UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
        
        // use spring animations
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
        
            // read current animation value
            switch self.currentAnimation {
            case 0:
                // scale up imageView
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                break
            case 1:
                // clear all changes made by transforms
                self.imageView.transform = .identity
            case 2:
                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
            case 3:
                self.imageView.transform = .identity
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
            case 5:
                self.imageView.transform = .identity
            case 6:
                self.imageView.alpha = 0.1
                self.imageView.backgroundColor = .green
            case 7:
                self.imageView.alpha = 1
                self.imageView.backgroundColor = .clear
            default:
                break
            }
        }) { finished in
            // show button after animation
            sender.isHidden = false
        }
        
        currentAnimation += 1
        
        // create continuous loop
        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
    
}

