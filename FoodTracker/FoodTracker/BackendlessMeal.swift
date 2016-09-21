//
//  BackendlessMeal.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/21/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import Foundation

class BacklendlessMeal: NSObject {
    
    var objectId: String?
    var message: String?
    var authorEmail: String?
    var topicId: Int = 0
    //extra for meal
    var name: String
    var photoUrl: String?
    var rating: Int


    
    init?(objectId: String?, message: String?, authorEmail: String?, topicId: Int = 0, name: String, photoUrl: String, rating: Int) {
        // Initialize stored properties.
        self.objectId = objectId
        self.message = message
        self.authorEmail = authorEmail
        self.topicId = topicId
        self.name = name
        self.photoUrl = photoUrl
        self.rating = rating
        
        super.init()
        
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
    
    
}
