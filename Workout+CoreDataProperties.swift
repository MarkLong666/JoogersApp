//
//  Workout+CoreDataProperties.swift
//  joggers
//
//  Created by Long Baolin on 16/4/14.
//  Copyright © 2016年 Lintasty. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Workout {

    @NSManaged var date: Date?
    @NSManaged var distance: NSNumber?
    @NSManaged var pace: NSNumber?
    @NSManaged var steps: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var photo: Data?

}
