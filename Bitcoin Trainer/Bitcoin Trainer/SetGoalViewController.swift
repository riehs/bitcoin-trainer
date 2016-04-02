//
//  SetGoalViewController.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 8/24/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit
import CoreData

class SetGoalViewController: UIViewController {

    @IBOutlet weak var workoutCountField: UITextField!
    @IBOutlet weak var prizeField: UITextField!

    @IBAction func setGoal(sender: AnyObject) {

		Goals.sharedInstance().goals[0].workoutCount = Int32(workoutCountField.text!)!
		Goals.sharedInstance().goals[0].prize = prizeField.text!
		Goals.sharedInstance().goals[0].date = NSDate()

        CoreDataStackManager.sharedInstance().saveContext()

		self.dismissViewControllerAnimated(true, completion: nil)
    }


	@IBAction func dismissSetGoal(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
