//
//  ViewController.swift
//  milestone9
//
//  Created by Sc0tt on 27/12/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet var imageView: UIImageView!
    // users selected image
    var importedImage: UIImage!
    var headerText: String?
    var footerText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meme Generator"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeImage))
    }

    @IBAction func importImage(_ sender: Any) {
        // present image picker allowing user to select an image
        // ensure 'Privacy - Photo Library Additions' are set in info.plist
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated:  true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // look for selected image
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        // assign selected image to currentImage so it can be modified
        
        imageView.image = image
        importedImage = image
    }

    
    @IBAction func headerButton(_ sender: Any) {
        let ac = UIAlertController(title: "Enter Header Text", message: nil, preferredStyle: .alert)
        // text field to capture input
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] action in
            // check for user input
            guard let headerInput = ac?.textFields?[0].text else { return }
            //print("\(headerInput)")
            
            self.headerText = headerInput
            self.addText()
        }))
        
        present(ac, animated: true)
        
        
    }
    

    @IBAction func footerButton(_ sender: Any) {
        let ac = UIAlertController(title: "Enter Footer Text", message: nil, preferredStyle: .alert)
        // text field to capture input
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] action in
            // check for user input
            guard let footerInput = ac?.textFields?[0].text else { return }
            
            print("\(footerInput)")
            
            self.footerText = footerInput
            self.addText()
        }))
        present(ac, animated: true)
    }
    
    func addText() {
        guard let image = importedImage else { return }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let renderedImage = renderer.image { ctx in
            image.draw(at: CGPoint(x: 0, y: 0))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 75),
                // add black 'outline' to text
                // ensure negative value as stroke is done on inside
                .strokeWidth: -2.5,
                .strokeColor: UIColor.black,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            // draw header text
            if let headerText = self.headerText {
                let attributedString = NSAttributedString(string: headerText, attributes: attrs)
                
                attributedString.draw(with: CGRect(x: 0, y: 20, width: image.size.width, height: 180), options: .usesLineFragmentOrigin, context: nil)
            }
            
            // draw footer text
            if let footerText = self.footerText {
                let attributedString = NSAttributedString(string: footerText, attributes: attrs)
                    
                attributedString.draw(with: CGRect(x: 0, y: image.size.height - 110, width: image.size.width, height: 90), options: .usesLineFragmentOrigin, context: nil)
                }
        }
        
        imageView.image = renderedImage
            
    }
    
    @objc func removeImage() {
        imageView.image = nil
    }
    
    @objc func shareImage() {
        let items = [imageView.image]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}
