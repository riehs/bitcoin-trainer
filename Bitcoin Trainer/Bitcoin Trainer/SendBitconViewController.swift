//
//  SendBitconViewController.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 8/29/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit

class SendBitcoinViewController: UIViewController {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	//The user presses the Cancel button.
    @IBAction func dismissSendBitcoin(_ sender: AnyObject) {

        self.dismiss(animated: true, completion: nil)
    }


    @IBAction func sendBitcoinButton(_ sender: AnyObject) {

        sendBitcoin(addressTextField.text!, amount: amountTextField.text!)
    }


	override func viewDidLoad() {
		super.viewDidLoad()
		
		//The activity indicator is hidden when the view first loads.
		activityIndicator.isHidden = true
	}


    func sendBitcoin(_ address: String, amount: String) {
		
		//Make the activity indicator visible.
		activityIndicator.isHidden = false
		
		BitcoinAddress.sharedInstance().sendBitcoin(address, amount: amount) { (success, errorString) in
			if  success {
				DispatchQueue.main.async(execute: { () -> Void in
					self.activityIndicator.isHidden = true
					self.dismiss(animated: true, completion: nil)
				});
			} else {
				DispatchQueue.main.async(execute: { () -> Void in
					self.activityIndicator.isHidden = true
					self.errorAlert("Error", error: errorString!)
				});
			}
		}
	}


	//Creates an Alert-style error message.
	func errorAlert(_ title: String, error: String) {
		let controller: UIAlertController = UIAlertController(title: title, message: error, preferredStyle: .alert)
		controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(controller, animated: true, completion: nil)
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
