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
    @IBAction func dismissSendBitcoin(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func sendBitcoinButton(sender: AnyObject) {

        sendBitcoin(addressTextField.text!, amount: amountTextField.text!)
    }


	override func viewDidLoad() {
		super.viewDidLoad()
		
		//The activity indicator is hidden when the view first loads.
		activityIndicator.hidden = true
	}


    func sendBitcoin(address: String, amount: String) {
		
		//Make the activity indicator visible.
		activityIndicator.hidden = false
		
		BitcoinAddress.sharedInstance().sendBitcoin(address, amount: amount) { (success, errorString) in
			if  success {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.activityIndicator.hidden = true
					self.dismissViewControllerAnimated(true, completion: nil)
				});
			} else {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.activityIndicator.hidden = true
					self.errorAlert("Error", error: "Cannot send Bitcoin. Confirm that the address is correct and your balance is high enough to allow for a 10000 satoshi fee.")
				});
			}
		}
	}


	//Creates an Alert-style error message.
	func errorAlert(title: String, error: String) {
		let controller: UIAlertController = UIAlertController(title: title, message: error, preferredStyle: .Alert)
		controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		presentViewController(controller, animated: true, completion: nil)
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
