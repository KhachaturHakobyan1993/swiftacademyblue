//
//  ViewController.swift
//  Selfie Share
//
//  Created by Khachatur Hakobyan on 1/5/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController {
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertsierAssistant: MCAdvertiserAssistant!
    var images = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupMultipeerConnectivity()
    }
    
    
    // MARK: - Methods Setup -

    private func setup() {
        self.title = "Selfie Share"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(ViewController.showImagePickerVC))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.showConnectionPrompt))
    }
    
    private func setupMultipeerConnectivity() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        debugPrint(UIDevice.current.name)
        self.mcSession = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self
    }

    // MARK: - Methods -
    
    @objc func showImagePickerVC() {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = self
        pickerVC.allowsEditing = true
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    @objc func showConnectionPrompt() {
        let alertVC = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        alertVC.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func startHosting(action: UIAlertAction) {
        self.mcAdvertsierAssistant = MCAdvertiserAssistant(serviceType: "hws-SelfieShare", discoveryInfo: nil, session: self.mcSession)
        self.mcAdvertsierAssistant.start()
    }
    
    func joinSession(action: UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-SelfieShare", session: self.mcSession)
        mcBrowser.delegate = self
        self.present(mcBrowser, animated: true, completion: nil)
    }
    
    func sendImageToPeers(image: Data?) {
        guard let imgData = image else { return }
        do {
            try self.mcSession.send(imgData, toPeers: self.mcSession.connectedPeers, with: .reliable)
        } catch {
            let alertVC = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - UICollectionViewDataSource -
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        guard let imageView = cell.viewWithTag(1000) as? UIImageView else { return cell }
        imageView.image = self.images[indexPath.row]
        return cell
    }
}


// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate -

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let choosedImage = info[.editedImage] as? UIImage else { return }
        self.dismiss(animated: true, completion: nil)
        self.images.insert(choosedImage, at: 0)
        self.collectionView.reloadData()
        self.sendImageToPeers(image: choosedImage.pngData())
    }
}


// MARK: - MCSessionDelegate -

extension ViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            debugPrint("Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            debugPrint("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            debugPrint("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let receivedImage = UIImage(data: data) else { return }
        DispatchQueue.main.async {
            self.images.insert(receivedImage, at: 0)
            self.collectionView.reloadData()
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        debugPrint("didReceive stream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        debugPrint("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        debugPrint("didChange")
    }
}


// MARK: - MCBrowserViewControllerDelegate -

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
