//
//  ViewController.swift
//  UserDefaults A
//
//  Created by Khachatur Hakobyan on 12/21/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var people = [Person]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.fetchImagesFromUserDefaults()
    }

    
    // MARK: - Methods -
    
    func setup() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.addNewPerson))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ViewController.removeAllImages))
    }
    
    func fetchImagesFromUserDefaults() {
        let defaults = UserDefaults.standard
        guard let savedPeopleData = defaults.value(forKey: "people") as? Data,
            let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeopleData) as? [Person] else { return }
        self.people = decodedPeople ?? [Person]()
        self.collectionView.reloadData()
    }
    
    func fetchImagesFromDocumentDirectory() {
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: self.getDocumentsDirectory().path) else { return }
        for oneItem in items {
            let newPerson = Person(name: "Unknown", image: oneItem)
            self.people.append(newPerson)
        }
        self.collectionView.reloadData()
    }
    
    @objc func addNewPerson() {
        self.showImagePickerVC()
    }
    
    func showImagePickerVC() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        self.present(imagePickerVC, animated: true, completion: nil)
    }
    
    
    @objc func removeAllImages() {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        guard let dirPath = paths.first else { return }
        let filePath = "\(dirPath)/"
        
        let items = try! fileManager.contentsOfDirectory(atPath: filePath)
        
        for one in items {
            do {
                try fileManager.removeItem(atPath: filePath + one)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
        self.people.removeAll()
        self.collectionView.reloadData()
    }
    
    func save() {
        guard let savedData = try? NSKeyedArchiver.archivedData(withRootObject: self.people, requiringSecureCoding: false) else { return }
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "people")
    }
    
    
    // MARK: - UICollectionViewDataSource -
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.navigationItem.leftBarButtonItem?.isEnabled = !self.people.isEmpty
        return self.people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = self.getDocumentsDirectory().appendingPathComponent(person.image)
        
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let alertVC = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        alertVC.addTextField()
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertVC.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, alertVC] _ in
            let newName = alertVC.textFields![0]
            person.name = newName.text!
            self.save()
            self.collectionView?.reloadData()
        })
        
        self.present(alertVC, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate -

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = self.getDocumentsDirectory().appendingPathComponent(imageName)
      
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        self.people.append(person)
        self.collectionView?.reloadData()
        
        self.dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

