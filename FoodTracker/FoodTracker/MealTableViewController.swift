//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/15/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController {

    // MARK: Properties
    
    //class Meal is same as MealData on other foodtracker
    //class BackendlessMeal is the same as Meal on other foodtracker 
    
    var meals = [Meal]()
    
    let backendless = Backendless.sharedInstance()!
    
    // More info on NSCache:
    // http://nshipster.com/nscache/
    // http://stackoverflow.com/questions/10502809/objective-c-benefits-of-using-nscache-over-a-static-nsmutabledictionary
    // http://blog.csdn.net/chuanyituoku/article/details/17336443
    
    // Create a cache that uses keys of type NSString to point to types of UIImage.
    var imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageCache.countLimit = 50 // Cache up to 50 UIImage(s)
        
        // Add support for pull-to-refresh on the table view.
        self.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        if BackendlessManager.sharedInstance.isUserLoggedIn() {
           
            refresh(sender: self)
            
        } else {
            
            // Load any saved meals, otherwise load sample data.
            if let savedMeals = loadMealsFromArchiver() {
                meals += savedMeals
            } else {
                // Load the sample data.
                
                // HACK: Disabled sample meal data for now!
               // loadSampleMeals()
            }
        }
    }
    
    //cant set parameter to nil so its set to AnyObject
    func refresh(sender: AnyObject) {
        
        if BackendlessManager.sharedInstance.isUserLoggedIn() {
            
            BackendlessManager.sharedInstance.loadMeals(
                
                completion: { mealData in
                    
                    self.meals = mealData
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                },
                
                error: {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
            })
        }
    }

    
    func loadSampleMeals() {
        
        let photo1 = UIImage(named: "meal1")!
        let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4)!
        
        let photo2 = UIImage(named: "meal2")!
        let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5)!
        
        let photo3 = UIImage(named: "meal3")!
        let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3)!
        
        meals += [meal1, meal2, meal3]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[(indexPath as NSIndexPath).row]

        cell.nameLabel.text = meal.name
        
        cell.photoImageView.image = nil
        
        if BackendlessManager.sharedInstance.isUserLoggedIn() && meal.thumbnailUrl != nil {
            
            if imageCache.object(forKey: meal.thumbnailUrl! as NSString) != nil {
                
                // If the URL for the thumbnail is in the cache already - get the UIImage that belongs to it.
                cell.photoImageView.image = imageCache.object(forKey: meal.thumbnailUrl! as NSString)
                
            } else {
                
                cell.spinner.startAnimating()
                
                loadImageFromUrl(thumbnailUrl: meal.thumbnailUrl!,
                                 
                                 completion: { data in
                                    
                                    // We got the image data! Use it to create a UIImage for our cell's
                                    // UIImageView. Then, stop the activity spinner.
                                    if let image = UIImage(data: data) {
                                        
                                        cell.photoImageView.image = image
                                        
                                        // Since we went to the trouble of pulling down the image data and
                                        // building a UIImage lets cache the UIImage using the URL as the key.
                                        self.imageCache.setObject(image, forKey: meal.thumbnailUrl! as NSString)
                                    }
                                    
                                    cell.spinner.stopAnimating()
                    },
                                 
                                 loadError: {
                                    cell.spinner.stopAnimating()
                })
            }
            
        } else {
            cell.photoImageView.image = meal.photo
        }
        
        cell.ratingControl.rating = meal.rating
        
        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if BackendlessManager.sharedInstance.isUserLoggedIn() {
                
                // Find the MealData in the data source that we wish to delete.
                let mealToRemove = meals[indexPath.row]
                
                BackendlessManager.sharedInstance.removeMeal(mealToRemove: mealToRemove,
                                                             
                    completion: {
                    
                        // It was removed from the database, now delete the row from the data source.
                        self.meals.remove(at: (indexPath as NSIndexPath).row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    },
                    
                    error: {
                        
                        // It was NOT removed - tell the user and DON'T delete the row from the data source.
                        let alertController = UIAlertController(title: "Remove Failed",
                                                                message: "Oops! We couldn't remove your Meal at this time.",
                                                                preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                )

                
            } else {
                
                // Delete the row from the data source
                meals.remove(at: (indexPath as NSIndexPath).row)
                
                // Save the meals.
                saveMealsToArchiver()
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDetail" {
            
            let mealDetailViewController = segue.destination as! MealViewController
            
            // Get the cell that generated this segue.
            if let selectedMealCell = sender as? MealTableViewCell {
                
                let indexPath = tableView.indexPath(for: selectedMealCell)!
                let selectedMeal = meals[(indexPath as NSIndexPath).row]
                mealDetailViewController.meal = selectedMeal
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new meal.")
        }
    }
    
    
    @IBAction func unwindToMealList(_ sender: UIStoryboardSegue) {
        // the optional type cast operator (as?) trys to downcast the source view controller of the segue, to type MealViewController and returns an optional value, which will be nil if the downcast wasn’t possible. If the downcast succeeds, the code assigns that view controller to the local constant sourceViewController. (If either the downcast fails or the meal property on sourceViewController is nil, the condition evaluates to false and the if statement doesn’t get executed.)
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            //checks whether a row in the table view is selected
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                meals[(selectedIndexPath as NSIndexPath).row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                    // Add a new meal.
                    let newIndexPath = IndexPath(row: meals.count, section: 0)
                    meals.append(meal)
                    tableView.insertRows(at: [newIndexPath], with: .bottom)
                }
            if !BackendlessManager.sharedInstance.isUserLoggedIn() {
                // We're not logged in - save the meals using NSKeyedUnarchiver.
                saveMealsToArchiver()
            }
        }
    }

    // MARK: NSCoding
    
    func loadImageFromUrl(thumbnailUrl: String, completion: @escaping (Data) -> (), loadError: @escaping () -> ()) {
        
        let url = URL(string: thumbnailUrl)!
        
        print("loadImageFromUrl: \(url)")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error == nil {
                
                do {
                    let data = try Data(contentsOf: url, options: [])
                    
                    DispatchQueue.main.async {
                        completion(data)
                    }
                    
                } catch {
                    print("NSData Error: \(error)")
                    DispatchQueue.main.async {
                        loadError()
                    }
                }
                
            } else {
                print("NSURLSession Error: \(error)")
                DispatchQueue.main.async {
                    loadError()
                }
            }
        })
        
        task.resume()
    }
    
    func saveMealsToArchiver() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save meals...")
        }
    }

    
    func loadMealsFromArchiver() -> [Meal]? {
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal
            .ArchiveURL.path) as? [Meal]
    }

    
}


