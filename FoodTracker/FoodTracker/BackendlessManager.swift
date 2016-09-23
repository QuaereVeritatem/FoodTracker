//
//  BackendlessManager.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/22/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import Foundation

// The BackendlessManager class below is using the Singleton pattern.
// A singleton class is a class which can be instantiated only once.
// In other words, only one instance of this class can ever exist.
// The benefit of a Singleton is that its state and functionality are
// easily accessible to any other object in the project.

class BackendlessManager {
    
    // This gives access to the one and only instance.
    static let sharedInstance = BackendlessManager()
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    
    let backendless = Backendless.sharedInstance()!
    
    //***ALL instances of CLass Meal must be changed to BackendlessMeal [DONE]
    
    let VERSION_NUM = "v1"
    let APP_ID = "BB167472-BAE1-DCBC-FF4C-0E475BF35E00"
    let SECRET_KEY = "CA8325C6-6AF9-E6C5-FF4D-E6ED01505D00"
    
    let EMAIL = "test@gmail.com" // Doubles as User Name
    let PASSWORD = "password"
    
    func initApp() {
        
        // First, init Backendless!
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        backendless.userService.setStayLoggedIn(true)
    }
    
    func isUserLoggedIn() -> Bool {
        
        let isValidUser = backendless.userService.isValidUserToken()
        
        if isValidUser != nil && isValidUser != 0 {
            return true
        } else {
            return false
        }
    }
    
    func registerTestUser() {
        
        let user: BackendlessUser = BackendlessUser()
        user.email = EMAIL as NSString!
        user.password = PASSWORD as NSString!
        
        backendless.userService.registering( user,
                                             
                                             response: { (user: BackendlessUser?) -> Void in
                                                
                                                print("User was registered: \(user?.objectId)")
                                                
                                                self.loginTestUser()
            },
                                             
                                             error: { (fault: Fault?) -> Void in
                                                print("User failed to register: \(fault)")
                                                
                                                print(fault?.faultCode)
                                                
                                                // If fault is for "User already exists." - go ahead and just login!
                                                if fault?.faultCode == "3033" {
                                                    self.loginTestUser()
                                                }
            }
        )
    }
    
    func loginTestUser() {
        
        backendless.userService.login( self.EMAIL, password: self.PASSWORD,
                                       
                                       response: { (user: BackendlessUser?) -> Void in
                                        print("User logged in: \(user!.objectId)")
            },
                                       
                                       error: { (fault: Fault?) -> Void in
                                        print("User failed to login: \(fault)")
            }
        )
    }
    
    func saveTestData() {
        
        let newMeal = BackendlessMeal()
        newMeal.name = "Test Meal #1"
        newMeal.photoUrl = "https://guildsa.org/wp-content/uploads/2016/09/meal1.png"
        newMeal.rating = 5
        
        backendless.data.save( newMeal,
                               
                               response: { (entity: Any?) -> Void in
                                
                                let meal = entity as! BackendlessMeal
                                
                                print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
            },
                               
                               error: { (fault: Fault?) -> Void in
                                print("Meal failed to save: \(fault)")
            }
        )
    }
    
    func loadTestData() {
        
        let dataStore = backendless.persistenceService.of(BackendlessMeal.ofClass())
        
        dataStore?.find(
            
            { (meals: BackendlessCollection?) -> Void in
                
                print("Find attempt on all Meals has completed without error!")
                print("Number of Meals found = \((meals?.data.count)!)")
                
                for meal in (meals?.data)! {
                    
                    let meal = meal as! Meal
                    
                    print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                }
            },
            
            error: { (fault: Fault?) -> Void in
                print("Meals were not fetched: \(fault)")
            }
        )
    }
    
   func saveMeal(mealData: Meal, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        let mealToSave = BackendlessMeal()
        mealToSave.name = mealData.name
        mealToSave.photoUrl = mealData.photoUrl
        mealToSave.rating = mealData.rating
        
        // If the MealData object has an objectId - set it so we can update an existing Meal.
        // Otherwise, we're creating a new Meal.
        if let objectId = mealData.objectId {
            mealToSave.objectId = objectId
        }
        
        backendless.data.save( mealToSave,
                               
                               response: { (entity: Any?) -> Void in
                                
                                let meal = entity as! BackendlessMeal
                                
                                print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                                
                                mealData.objectId = meal.objectId
                                
                                completion()
            },
                               
                               error: { (fault: Fault?) -> Void in
                                print("Meal failed to save: \(fault)")
            }
        )
    }
    
    func loadMeals(completion: @escaping ([Meal]) -> ()) {
        
        let dataStore = backendless.persistenceService.of(BackendlessMeal.ofClass())
        
        let dataQuery = BackendlessDataQuery()
        // Only get the Meals that belong to our logged in user!
        dataQuery.whereClause = "ownerId = '\(backendless.userService.currentUser.objectId!)'"
        
        dataStore?.find( dataQuery,
                         
                         response: { (meals: BackendlessCollection?) -> Void in
                            
                            print("Find attempt on all Meals has completed without error!")
                            print("Number of Meals found = \((meals?.data.count)!)")
                            
                            var mealData = [Meal]()
                            
                            for meal in (meals?.data)! {
                                
                                let meal = meal as! BackendlessMeal
                                
                                print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                                
                                let newMealData = Meal(name: meal.name!, photo: nil, rating: meal.rating)
                                
                                if let newMealData = newMealData {
                                    
                                    newMealData.objectId = meal.objectId
                                    newMealData.photoUrl = meal.photoUrl
                                    
                                    mealData.append(newMealData)
                                }
                            }
                            
                            // Whatever meals we found on the database - return them.
                            completion(mealData)
            },
                         
                         error: { (fault: Fault?) -> Void in
                            print("Meals were not fetched: \(fault)")
            }
        )
    }
    
    func removeMeal(mealToRemove: Meal, completion: () -> (), error: @escaping () -> ()) {
        
        let meal = BackendlessMeal()
        
        if let objectId = mealToRemove.objectId {
            meal.objectId = objectId
        }
        
        print("Remove Meal: \(meal.objectId!)")
        
        let dataStore = backendless.persistenceService.of(BackendlessMeal.ofClass())
        //dont delete something until it was removed from the database first!
        var fault: Fault?
        let result = dataStore?.remove(meal, fault: &fault)
        
        if fault == nil {
            
            print("One Meal has been removed: \(result)")
            
            completion()
            
        } else {
            print("Server reported an error on attempted removal: \(fault)")
            
            error()
        }
    }
}
