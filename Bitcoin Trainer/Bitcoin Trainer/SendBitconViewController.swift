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

    @IBAction func dismissSendBitcoin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func sendBitcoinButton(sender: AnyObject) {

		//TODO - confirm that fields contain valid data.
        sendBitcoin(addressTextField.text!, amount: amountTextField.text!)

    }


	override func viewDidLoad() {
		super.viewDidLoad()
	}


    func sendBitcoin(address: String, amount: String) {
		
		BitcoinAddress.sharedInstance().sendBitcoin(address, amount: amount) { (success, errorString) in
			if  success {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.dismissViewControllerAnimated(true, completion: nil)
				});
			} else {
				print(errorString)
			}
		}
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
