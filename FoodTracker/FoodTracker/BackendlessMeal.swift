//
//  BackendlessMeal.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/21/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import Foundation

//Meal model for saving to Backendless (this is Class Meal from GSA foodtracker)
class BackendlessMeal: NSObject {
    
    var objectId: String?
    var name: String?
    var photoUrl: String?
    var thumbnailUrl: String?
    var rating: Int = 0
}
