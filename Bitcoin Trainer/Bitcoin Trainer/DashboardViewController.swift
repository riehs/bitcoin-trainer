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

open class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var balanceDisplay: UILabel!

    @IBOutlet weak var statusDisplay: UITextView!

    @IBOutlet weak var setGoalButton: UIButton!

    @IBOutlet weak var sendBitcoinButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	var healthKitManager: HealthKitManager = HealthKitManager()
	var workouts = [HKWorkout]()

	//Workout dates will be displayed in this format.
	lazy var dateFormatter:DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		formatter.dateStyle = .medium
		return formatter;
	}()


	//Goals are persisted in Core Data:

	//Useful for saving data into the Core Data context.
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext!
	}


	//Bitcoin address information is persisted with NSCoding:
	
	//Defining the file path where the archived data will be stored by the NSKeyedArchiver.
	var filePath: String {
		let manager = FileManager.default
		let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
		return url!.appendingPathComponent("bitcoinAddress").path
	}


	open override func viewDidLoad() {
		super.viewDidLoad()
	
		//Calls the applicationWillEnterForeground function when the app transitions out of the background state. Necessary for refreshing workout data.
		NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)

		setGoalButton.isEnabled = true
		sendBitcoinButton.isEnabled = true
		
		activityIndicator.isHidden = true

		//Fetch goal from Core Data.
		Goals.sharedInstance().goals = fetchGoal()

		//If the app is being run for the first time, and there is no goal in the array, a dummy goal is created.
		if Goals.sharedInstance().goals.count == 0 {
			Goals.sharedInstance().goals.append(Goal(workoutCount: 0, prize: "No Goal Set", date: Date(),context: sharedContext))
			CoreDataStackManager.sharedInstance().saveContext()
			self.statusDisplay.text = Goals.sharedInstance().goals[0].prize
		}

		//Request HealthKit authorization.
		healthKitManager.authorizeHealthKit { (authorized,  error) -> Void in
			if authorized {
				print("HealthKit authorization received.")
			}
			else
			{
				print("HealthKit authorization denied!")
				if error != nil {
					print("\(String(describing: error))")
				}
			}
		}

		//Unarchiving any saved Bitcoin address information that was saved with NSCoding.
		if let bitcoinAddress = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? BitcoinAddress {
			BitcoinAddress.sharedInstance().setProperties(bitcoinAddress.address, label: bitcoinAddress.label)
			
		}

		//Generates a new Bitcoin address if one has not already been created.
		if BitcoinAddress.sharedInstance().address == "Error" {
			BitcoinAddress.sharedInstance().createProperties() { (success, errorString) in
				if success {
					DispatchQueue.main.async(execute: { () -> Void in
						
						//A new Bitcoin address will always have a balance of 0.
						self.balanceDisplay.text = "0"
					});
				}
			}
		} else {

			//Start the activity indicator.
			activityIndicator.isHidden = false

			BitcoinAddress.sharedInstance().getBalance(balanceDisplay) { (success, errorString) in

				//Stop the activity indicator.
				DispatchQueue.main.async(execute: { () -> Void in
					self.activityIndicator.isHidden = true
				});

				if !success {
					DispatchQueue.main.async(execute: { () -> Void in
						self.balanceDisplay.text = errorString
					});
				}
			}
		}
	}


	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshDashboard()
	}


	//Refreshes goal and balance information when a view controller is dismissed.
	open override func viewDidAppear(_ animated: Bool) {

		//Start the activity indicator.
		activityIndicator.isHidden = false

		BitcoinAddress.sharedInstance().getBalance(balanceDisplay) { (success, errorString) in

			//Stop the activity indicator.
			DispatchQueue.main.async(execute: { () -> Void in
				self.activityIndicator.isHidden = true
			});

			if !success {
				DispatchQueue.main.async(execute: { () -> Void in
					self.balanceDisplay.text = errorString
				});
			}
		}

		//Saves the Bitcoin address information.
		NSKeyedArchiver.archiveRootObject(BitcoinAddress.sharedInstance(), toFile: filePath)

		refreshDashboard()
		
	}


	@objc func applicationWillEnterForeground(_ notification: Notification) {
		refreshDashboard()
	}


	//Refreshes workout data and checks to see if the goal has been met.
	open func refreshDashboard() {

		//Read workouts from HealthKit.
		healthKitManager.readWorkouts({ (results, error) -> Void in
			if( error != nil )
			{
				print("Error reading workouts: \(error!.localizedDescription)")
				return;
			}
			else
			{
				print("Workouts read successfully!")
			}

			//Save workouts into array.
			self.workouts = results as! [HKWorkout]
			
			//Refresh tableview in main thread.
			DispatchQueue.main.async(execute: { () -> Void in
				self.tableView.reloadData()
				
				//If a goal has been set, check to see if it has been met.
				if Goals.sharedInstance().goals[0].prize != "No Goal Set" {
					
					//The goal has been met.
					if Int32(self.workouts.count) >= Goals.sharedInstance().goals[0].workoutCount {
						self.setGoalButton.isEnabled = true
						self.sendBitcoinButton.isEnabled = true
						self.statusDisplay.text = "You completed \(Goals.sharedInstance().goals[0].workoutCount) workouts. Buy your \(Goals.sharedInstance().goals[0].prize)!"
					
					//The goal has not yet been met.
					} else {
						self.setGoalButton.isEnabled = false
						self.sendBitcoinButton.isEnabled = false
						self.statusDisplay.text = "Complete \(Goals.sharedInstance().goals[0].workoutCount) workouts and buy your \(Goals.sharedInstance().goals[0].prize)!"
					}
				}
			});
			
		})
	}


	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return  workouts.count
	}


	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "workoutcellid", for: indexPath)

		//Get workout for the row. Display the workout date.
		let workout  = workouts[(indexPath as NSIndexPath).row]
		let startDate = dateFormatter.string(from: workout.startDate)
		cell.textLabel!.text = startDate

		return cell
	}


	//Loads the goal from Core Data.
	func fetchGoal() -> [Goal] {

		let error: NSErrorPointer? = nil
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
		let results: [AnyObject]?
		do {
			results = try sharedContext.fetch(fetchRequest)
		} catch let error1 as NSError {
			error??.pointee = error1
			results = nil
		}

		if error != nil {
			print("Error in fetchGoal(): \(String(describing: error))")
		}

		return results as! [Goal]
	}


	open override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
