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
    @IBOutlet weak var labelDisplay: UITextField!

	override func viewDidLoad() {

		super.viewDidLoad()

		addressDisplay.text = BitcoinAddress.sharedInstance().address
		labelDisplay.text = BitcoinAddress.sharedInstance().label
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
