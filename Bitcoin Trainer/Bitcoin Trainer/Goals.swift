//
//  Goals.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 3/28/16.
//  Copyright © 2016 Daniel Riehs. All rights reserved.
//

import Foundation
import CoreData

class Goals {

	var goals: [Goal] = [Goal]()

	//Allows other classes to reference a common instance of the goals array. There will neer be more than one goal in this array.
	class func sharedInstance() -> Goals {

		struct Singleton {
			static var sharedInstance = Goals()
		}
		return Singleton.sharedInstance
	}
}
