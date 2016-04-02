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

	//Allows other classes to reference a common instance of the memes array.
	class func sharedInstance() -> Goals {

		struct Singleton {
			static var sharedInstance = Goals()
		}
		return Singleton.sharedInstance
	}
}
