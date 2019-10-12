//
//  ViewController.swift
//  project10
//
//  Created by Sc0tt on 08/10/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit

// inherit from collection view controller
class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // button for adding images
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    
    // define number of items in selection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    // dequeue cells not in view [similar to tables]
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            // if we cant find PersonCell
            fatalError("Unable to dequeue a PersonCell.")
        }
        // assign persons name to label
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        // add border
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewPerson() {
        // create new picker and allow image editing
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated:  true)
    }
    
    // dictionary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // attempt to find edited image
        guard let image = info[.editedImage] as? UIImage else { return }
        
        // get documents directory and append file/image name
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        // write back to image path
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        // create new instance of person and append to array
        let person = Person(name: "Uknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }

    // find documents directory on device
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        // present list of user actions
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        // delete action controller
         ac.addAction(UIAlertAction(title: "Delete", style: .destructive) {
             [weak self] _ in
             let acDelete = UIAlertController(title: "This image will be deleted from the application.", message: nil, preferredStyle: .actionSheet)
             
             acDelete.addAction(UIAlertAction(title: "Delete", style: .destructive)
             {
                 [weak self] _ in
                 // remove tapped picture from people
                 self?.people.remove(at: indexPath.item)
                 self?.collectionView.reloadData()
             })
             acDelete.addAction(UIAlertAction(title: "Cancel", style: .cancel))
             self?.present(acDelete, animated: true)
         })
    
        // rename action controller
        ac.addAction(UIAlertAction(title: "Rename", style: .default)
        {
            [weak self] _ in
            let acRename = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
            acRename.addTextField()
            
            // read text field and assign text to person name
            acRename.addAction(UIAlertAction(title: "OK", style: .default) {
                [weak self, weak acRename] _ in
                guard let newName = acRename?.textFields?[0].text else { return }
                person.name = newName
                self?.collectionView.reloadData()
            })
    
            acRename.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(acRename, animated: true)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

