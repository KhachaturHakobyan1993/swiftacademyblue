//
//  ViewController.swift
//  Secret Swift
//
//  Created by Khachatur Hakobyan on 12/31/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    @IBOutlet var secretTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupKeyboardNotifications()
    }
    
    
    // MARK: - Methods Setup -

    private func setup() {
        self.title = "Nothing to see here"
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            self.secretTextView.contentInset = UIEdgeInsets.zero
        } else {
            self.secretTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        self.secretTextView.scrollIndicatorInsets = self.secretTextView.contentInset
        
        let selectedRange = self.secretTextView.selectedRange
        self.secretTextView.scrollRangeToVisible(selectedRange)
    }
    
    
    // MARK: - Methods -
    
    func unlockSecretMessage() {
        self.secretTextView.isHidden = false
        self.title = "Secret stuff!"
        guard let text = KeychainWrapper.standard.string(forKey: "SecretMessage") else { return }
        self.secretTextView.text = text
    }
    
    @objc func saveSecretMessage() {
        guard !self.secretTextView.isHidden else { return }
        KeychainWrapper.standard.set(self.secretTextView.text, forKey: "SecretMessage")
        self.secretTextView.resignFirstResponder()
        self.secretTextView.isHidden = true
        self.title = "Nothing to see here"
    }
    
    func showAlertError(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    // MARK: - IBActions -
    
    @IBAction func authenticateTapped(_ sender: AnyObject) {
        let context = LAContext()
        var error: NSError?
        
        
        #if targetEnvironment(simulator)
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            self.showAlertError(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.")
            return
        }
        let reason = "Identify yourself!"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {[unowned self] (success, authenticationError) in
            DispatchQueue.main.async {
                guard success else {
                    self.showAlertError(title: "Authentication failed", message: "You could not be verified; please try again.")
                    return
                }
                self.unlockSecretMessage()
            }
        }
        #else
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            self.showAlertError(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.")
            return
        }
        let reason = "Identify yourself!"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[unowned self] (success, authenticationError) in
            DispatchQueue.main.async {
                guard success else {
                    self.showAlertError(title: "Authentication failed", message: "You could not be verified; please try again.")
                    return
                }
                self.unlockSecretMessage()
            }
        }
        #endif
    }
}
