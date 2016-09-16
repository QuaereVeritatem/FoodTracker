//
//  Meal.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/15/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import UIKit

class Meal: NSObject, NSCoding {
    // MARK: Properties
    
    // MARK: Archiving Paths
    
    //a persistent path on the file system where data will be saved and loaded..
    //access the path using the syntax Meal.ArchiveURL.path!(when accessed outside the class)
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("meals")
    //constants marked with static keyword apply to the class instead of an instance of the class.
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
    }
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int) {
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        
        super.init()
        
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
    // MARK: NSCoding
    
    //The encodeWithCoder(_:) method prepares the class’s information to be archived, and the initializer unarchives the data when the class is created.
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        // Because photo is an optional property of Meal, use conditional cast.
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating)
    }
}
