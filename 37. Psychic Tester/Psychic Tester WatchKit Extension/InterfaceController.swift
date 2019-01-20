//
//  InterfaceController.swift
//  Psychic Tester WatchKit Extension
//
//  Created by Khachatur Hakobyan on 1/20/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import WatchConnectivity
import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var welcomeTextLabel: WKInterfaceLabel!
    @IBOutlet var redyButton: WKInterfaceButton!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        super.willActivate()
        self.checkWCSession()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    // MARK: - Methods Setup -
    
    private func checkWCSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Methods -
    
    @objc func hideMessage() {
        self.welcomeTextLabel.setHidden(true)
    }
    
    
    // MARK: - Methods IBActions -
    
    @IBAction func readyButtonTapped() {
        self.welcomeTextLabel.setHidden(true)
        self.redyButton.setHidden(true)
    }
}


// MARK: - WCSessionDelegate -

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint(#function)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        WKInterfaceDevice().play(.click)
        guard let message = message["Message"] as? String else { return }
        self.welcomeTextLabel.setText(message)
        self.welcomeTextLabel.setHidden(false)
        self.perform(#selector(InterfaceController.hideMessage), with: nil, afterDelay: 2)
    }
}
