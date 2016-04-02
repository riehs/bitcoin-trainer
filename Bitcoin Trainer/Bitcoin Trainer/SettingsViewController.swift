//
//  SettingsViewController.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 8/24/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

	@IBOutlet weak var addressDisplay: UITextField!
    @IBOutlet weak var guidDisplay: UITextField!
    @IBOutlet weak var passwordDisplay: UITextField!

	override func viewDidLoad() {

		super.viewDidLoad()

		//Using these three pieces of information, a user can restore lost Bitcoin at blockchain.info.

		addressDisplay.text = BitcoinAddress.sharedInstance().address
		guidDisplay.text = BitcoinAddress.sharedInstance().guid
		passwordDisplay.text = BitcoinAddress.sharedInstance().password
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
