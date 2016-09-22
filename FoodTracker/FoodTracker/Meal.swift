//
//  Meal.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/15/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import UIKit

//This is class is equivalent to MealData on the other foodtracker [Done..delete this comment] 
class Meal: NSObject, NSCoding {
    
    // MARK: Common Properties Shared by Archiver and Backendless
    
    var name: String
    var rating: Int
    
    // MARK: Archiver Only Properties
    
    var photo: UIImage?
    
    // MARK: Backendless Only Properties
    
    var objectId: String?
    var photoUrl: String?
    
    // MARK: Archiving Paths
    //a persistent path on the file system where data will be saved and loaded..
    //access the path using the syntax Meal.ArchiveURL.path!(when accessed outside the class)
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    //constants marked with static keyword apply to the class instead of an instance of the class.
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
    }
    
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
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(photo, forKey: PropertyKey.photoKey)
        aCoder.encode(rating, forKey: PropertyKey.ratingKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Meal, use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.ratingKey)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating)
    }
}
