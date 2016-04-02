//
//  DashboardViewController.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 8/24/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

public class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var balanceDisplay: UILabel!

    @IBOutlet weak var statusDisplay: UITextView!

    @IBOutlet weak var setGoalButton: UIButton!

    @IBOutlet weak var sendBitcoinButton: UIButton!

	var healthKitManager: HealthKitManager = HealthKitManager()
	var workouts = [HKWorkout]()

	lazy var dateFormatter:NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.timeStyle = .ShortStyle
		formatter.dateStyle = .MediumStyle
		return formatter;
	}()


	//Useful for saving data into the Core Data context.
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext!
	}


	//Defining the file path where the archived data will be stored by the NSKeyedArchiver.
	var filePath: String {
		let manager = NSFileManager.defaultManager()
		let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
		return url!.URLByAppendingPathComponent("bitcoinAddress").path!
	}


	public override func viewDidLoad() {
		super.viewDidLoad()
	
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)

		setGoalButton.enabled = true
		sendBitcoinButton.enabled = true

		Goals.sharedInstance().goals = fetchGoal()

		if Goals.sharedInstance().goals.count == 0 {
			Goals.sharedInstance().goals.append(Goal(workoutCount: 0, prize: "No Goal Set", date: NSDate(),context: sharedContext))
			CoreDataStackManager.sharedInstance().saveContext()
			self.statusDisplay.text = Goals.sharedInstance().goals[0].prize
		}

		healthKitManager.authorizeHealthKit { (authorized,  error) -> Void in
			if authorized {
				print("HealthKit authorization received.")
			}
			else
			{
				print("HealthKit authorization denied!")
				if error != nil {
					print("\(error)")
				}
			}
		}

		//Unarchiving the saved array.
		if let bitcoinAddress = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? BitcoinAddress {
			BitcoinAddress.sharedInstance().setProperties(bitcoinAddress.password, address: bitcoinAddress.address, guid: bitcoinAddress.guid)
			
		}

		if BitcoinAddress.sharedInstance().address == "Error" {
			BitcoinAddress.sharedInstance().createProperties() { (success, errorString) in
				if success {
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						
						self.balanceDisplay.text = "0"
					});
				}
			}
		} else {
			BitcoinAddress.sharedInstance().getBalance(balanceDisplay) { (success, errorString) in
				if !success {
					self.balanceDisplay.text = errorString
				}
			}
		}
	}


	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshDashboard()
	}


	//Refreshes goal and balance information when a view controller is dismissed.
	public override func viewDidAppear(animated: Bool) {
		
		BitcoinAddress.sharedInstance().getBalance(balanceDisplay) { (success, errorString) in
			if !success {
				self.balanceDisplay.text = errorString
			}
		}
		NSKeyedArchiver.archiveRootObject(BitcoinAddress.sharedInstance(), toFile: filePath)
		refreshDashboard()
		
	}


	func applicationWillEnterForeground(notification: NSNotification) {
		refreshDashboard()
	}


	public func refreshDashboard() {
		healthKitManager.readWorkouts({ (results, error) -> Void in
			if( error != nil )
			{
				print("Error reading workouts: \(error.localizedDescription)")
				return;
			}
			else
			{
				print("Workouts read successfully!")
			}

			//Keep workouts and refresh tableview in main thread
			self.workouts = results as! [HKWorkout]
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.tableView.reloadData()
				if Goals.sharedInstance().goals[0].prize != "No Goal Set" {
					if Int32(self.workouts.count) >= Goals.sharedInstance().goals[0].workoutCount {
						self.setGoalButton.enabled = true
						self.sendBitcoinButton.enabled = true
						self.statusDisplay.text = "You Completed \(Goals.sharedInstance().goals[0].workoutCount) workouts. Buy your \(Goals.sharedInstance().goals[0].prize)!"
					} else {
						self.setGoalButton.enabled = false
						self.sendBitcoinButton.enabled = false
						self.statusDisplay.text = "Complete \(Goals.sharedInstance().goals[0].workoutCount) workouts and buy your \(Goals.sharedInstance().goals[0].prize)!"
					}
				}
			});
			
		})
	}


	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return  workouts.count
	}


	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("workoutcellid", forIndexPath: indexPath)

		// 1. Get workout for the row. Cell text: Workout Date

		let workout  = workouts[indexPath.row]
		let startDate = dateFormatter.stringFromDate(workout.startDate)
		cell.textLabel!.text = startDate

		return cell
	}


	//Loads the goal from Core Data.
	func fetchGoal() -> [Goal] {

		let error: NSErrorPointer = nil
		let fetchRequest = NSFetchRequest(entityName: "Goal")
		let results: [AnyObject]?
		do {
			results = try sharedContext.executeFetchRequest(fetchRequest)
		} catch let error1 as NSError {
			error.memory = error1
			results = nil
		}

		if error != nil {
			print("Error in fetchGoal(): \(error)")
		}

		return results as! [Goal]
	}


	public override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
