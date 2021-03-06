//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/14/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import UIKit
//save full size and thumbnail image first to get the url then save the meal
//chain succesful calls together(success call for a pic then save another

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var ratingControl: RatingControl!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var saveSpinner: UIActivityIndicatorView!
    
    
    /*
     This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: Meal? //class Meal is called 'MealData' in other foodtracker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            
            //loadimagefromUrl a renamed function
            if BackendlessManager.sharedInstance.isUserLoggedIn() && meal.photoUrl != nil {
                loadImageFromUrl(imageView: photoImageView, photoUrl: meal.photoUrl!)
            } else {
                photoImageView.image = meal.photo
            }
            
            ratingControl.rating = meal.rating
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidMealName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // If we already have a URL for an image - the user wants to do an image replacement.
                if meal?.photoUrl != nil {
                  meal?.replacePhoto = true
                }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
         saveButton.isEnabled = false
        
        let name = nameTextField.text ?? ""
        let rating = ratingControl.rating
        let photo = photoImageView.image
        
        if meal == nil {
            
            meal = Meal(name: name, photo: photo, rating: rating)

        } else {
            
            meal?.name = name
            meal?.photo = photo
            meal?.rating = rating
          
        }
        
        if BackendlessManager.sharedInstance.isUserLoggedIn() {
            
            // We're logged in - attempt to save to Backendless!
            saveSpinner.startAnimating()
            
            BackendlessManager.sharedInstance.saveMeal(mealData: meal!,
                                                       
                    completion: {
                                                        
                    // It was saved to the database!
                    self.saveSpinner.stopAnimating()
                        
                         self.meal?.replacePhoto = false // Reset this just in case we did a photo replacement.
                        
                        self.performSegue(withIdentifier: "unwindToMealList", sender: self)
                },
                    
                    error: {
                        
                        // It was NOT saved to the database! - tell the user and DON'T call performSegue.
                        self.saveSpinner.stopAnimating()
                        
                        let alertController = UIAlertController(title: "Save Error",
                                                                message: "Oops! We couldn't save your Meal at this time.",
                                                                preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                        self.saveButton.isEnabled = true

                })
            
        } else {
            
            // We're not logged in - just unwind and have MealTableViewController
            // save later using NSKeyedArchiver.
            self.performSegue(withIdentifier: "unwindToMealList", sender: self)
            
        }
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }
    }

    
    





    // This method lets you configure a view controller before it's presented.
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if saveButton === (sender as! UIBarButtonItem) {
            //if it’s nil, the nil coalescing operator then returns the empty string ("") instead.
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let rating = ratingControl.rating
            
// TODO: Fix
            let photoUrl = "https://guildsa.org/wp-content/uploads/2016/09/meal1.png"
            
            // Set the meal to be passed to MealTableViewController after the unwind segue.
            if meal == nil {

            meal = Meal(name: name, photo: photo, rating: rating)
                
            meal?.photoUrl = photoUrl
                
            } else {
                
                meal?.name = name
                meal?.photo = photo
                meal?.rating = rating
                meal?.photoUrl = photoUrl
            }
        }
    } */
    
    // MARK: Actions

    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }

    func loadImageFromUrl(imageView: UIImageView, photoUrl: String) {
        
        saveSpinner.startAnimating()
        
        let url = URL(string: photoUrl)!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error == nil {
                
                do {
                    
                    let data = try Data(contentsOf: url, options: [])
                    
                    DispatchQueue.main.async {
                        
                        // We got the image data! Use it to create a UIImage for our cell's
                        // UIImageView.
                        imageView.image = UIImage(data: data)
                         self.saveSpinner.stopAnimating()
                        
                        // TODO: Add activity indicator.
                        //activityIndicator.stopAnimating()
                    }
                    
                } catch {
                    print("NSData Error: \(error)")
                }
                
            } else {
                print("NSURLSession Error: \(error)")
            }
        })
        
        task.resume()
    }
}

