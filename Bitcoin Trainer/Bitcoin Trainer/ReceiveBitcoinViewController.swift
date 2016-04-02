//
//  ReceiveBitcoinViewController.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 8/29/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit

class ReceiveBitcoinViewController: UIViewController {

    @IBOutlet weak var addressDisplay: UITextField!

    @IBAction func dimissReceiveBitcoin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


	override func viewDidLoad() {
		super.viewDidLoad()

		addressDisplay.text = BitcoinAddress.sharedInstance().address
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
