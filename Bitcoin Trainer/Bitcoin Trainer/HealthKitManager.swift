//
//  HealthKitManager.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 3/28/16.
//  Copyright (c) 2016 Daniel Riehs. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {

	let healthKitStore:HKHealthStore = HKHealthStore()


	func authorizeHealthKit(_ completionHandler: ((_ success: Bool, _ errorString: String?) -> Void)!) {

		//The app only needs authorization to read data. No data is ever written back to HealthKit.
		let healthKitTypesToRead: Set<HKObjectType> = Set([ HKObjectType.workoutType() ])

		//If the store is not available (for instance, the user is on an iPad) return an error.
		if !HKHealthStore.isHealthDataAvailable()
		{
			let error = "HealthKit is not available in this device."
			completionHandler?(false, error)
		}

		//Request HealthKit authorization.
		healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, errorString) -> Void in

			//The app is not told if access is denied, so teh completion handler always returns success.
			completionHandler?(true, nil)
		}
	}


	//Read workouts that will count toward the goal.
	func readWorkouts(_ completionHandler: (([AnyObject]?, NSError?) -> Void)!) {

		//The current date and time.
		let endDate = Date()

		//The date the goal was created.
		let startDate = Goals.sharedInstance().goals[0].date

		//Only include items that occured after the start date.
		let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate, options: .strictStartDate)

		//Order the workouts by date:
		let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)

		//Create the query. Only workouts are included.
		let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
		{ (sampleQuery, results, error ) -> Void in
			
			if let queryError = error {
				print("There was an error while reading the samples: \(queryError.localizedDescription)")
			}
			completionHandler?(results,error as NSError?)
		}

		//Execute the query:
		healthKitStore.execute(sampleQuery)
	}
}
