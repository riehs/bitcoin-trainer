//
//  Goal.swift
//  Bitcoin Trainer
//
//  Created by Daniel Riehs on 3/28/16.
//  Copyright (c) 2016 Daniel Riehs. All rights reserved.
//

import CoreData

//Make Goal available to Objective-C code. (Necessary for Core Data.)
@objc(Goal)

//Make Goal a subclass of NSManagedObject. (Necessary for Core Data.)
class Goal: NSManagedObject {

	//Promoting these four properties to Core Data attributes by prefixing them with @NSManaged.
	@NSManaged var workoutCount: Int32
	@NSManaged var prize: String
	@NSManaged var date: Date


	//The standard Core Data init method.
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}


	//The init method needs to accept the shared context as one of its parameters.
	init(workoutCount: Int32, prize: String, date: Date, context: NSManagedObjectContext) {

		//The entity name here is the same as the entity name in the Model.xcdatamodeld file.
		let entity =  NSEntityDescription.entity(forEntityName: "Goal", in: context)!

		super.init(entity: entity, insertInto: context)

		self.workoutCount = workoutCount
		self.prize = prize
		self.date = date
	}
}
