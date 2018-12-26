//
//  ViewController.swift
//  InstaFilter
//
//  Created by Khachatur Hakobyan on 12/26/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit
import CoreImage


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensitySlider: UISlider!
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupCoreImageObjects()
    }
    
    
    // MARK: - Methods -
    
    func setup() {
        self.title = "YACIP"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.showImagePickerVC))
    }
    
    func setupCoreImageObjects() {
        self.context = CIContext()
        self.currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func showImagePickerVC() {
        let pickerVC = UIImagePickerController()
        pickerVC.allowsEditing = true
        pickerVC.delegate = self
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func applyProcessing() {
        guard self.currentImage != nil else { return }

        let inputKeys = self.currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            self.currentFilter.setValue(self.intensitySlider.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey){
            self.currentFilter.setValue(self.intensitySlider.value * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            self.currentFilter.setValue(self.intensitySlider.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            self.currentFilter.setValue(CIVector(x: self.currentImage.size.width / 2, y: self.currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        if let cgimg = self.context.createCGImage(self.currentFilter.outputImage!, from: self.currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            self.imageView.image = processedImage
        }
    }
    
    func showAlertForChangeFilter() {
        let alertVC = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: self.setFilter))
        alertVC.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: self.setFilter))
        alertVC.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: self.setFilter))
        alertVC.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: self.setFilter))
        alertVC.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: self.setFilter))
        alertVC.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: self.setFilter))
        alertVC.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: self.setFilter))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertVC, animated: true)
    }
    
    func showAlertDidFinishSaving(error: Error?) {
        let title = (error != nil ? "Save error" : "Saved!")
        let message = (error != nil ? error!.localizedDescription : "Your altered image has been saved to your photos.")
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertVC, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        guard self.currentFilter != nil, self.currentImage != nil else { return }
        self.title = action.title!.replacingOccurrences(of: "CI", with: "")
        self.currentFilter = CIFilter(name: action.title!)
        let beginImage = CIImage(image: self.currentImage!)
        self.currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        self.applyProcessing()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        self.showAlertDidFinishSaving(error: error)
    }
    
    
    // MARK: - IBActions -
    
    @IBAction func sliderIntensityChanged(_ sender: UISlider) {
        self.applyProcessing()
    }
    
    @IBAction func changeFilterButtonTapped(_ sender: UIButton) {
        self.showAlertForChangeFilter()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let imageForSave = self.imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(imageForSave, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let choosedImage = info[.editedImage] as? UIImage else { return }
        self.dismiss(animated: true, completion: nil)
        self.currentImage = choosedImage
        
        let beginImage = CIImage(image: self.currentImage)
        self.currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        self.applyProcessing()
    }
}


