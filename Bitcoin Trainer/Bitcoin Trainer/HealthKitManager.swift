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
	
	
	func authorizeHealthKit(completionHandler: ((success: Bool, errorString: String!) -> Void)!) {

		let healthKitTypesToRead: Set<HKObjectType> = Set([ HKObjectType.workoutType() ])

		// 3. If the store is not available (for instance, iPad) return an error and don't go on.
		if !HKHealthStore.isHealthDataAvailable()
		{
			let error = "HealthKit is not available in this device."
			completionHandler(success: false, errorString: error)
		}

		// 4.  Request HealthKit authorization
		healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) { (success, errorString) -> Void in
				//The app does not find out if access has been granted.
				completionHandler(success: true, errorString: nil)
		}
	}


	func readWorkouts(completionHandler: (([AnyObject]!, NSError!) -> Void)!) {

		let endDate = NSDate()

		let startDate = Goals.sharedInstance().goals[0].date

		let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .StrictStartDate)

		//Order the workouts by date:
		let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)

		//Create the query. Only workouts are included.
		let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
		{ (sampleQuery, results, error ) -> Void in
			
			if let queryError = error {
				print("There was an error while reading the samples: \(queryError.localizedDescription)")
			}
			completionHandler(results,error)
		}

		//Execute the query:
		healthKitStore.executeQuery(sampleQuery)
	}
}
