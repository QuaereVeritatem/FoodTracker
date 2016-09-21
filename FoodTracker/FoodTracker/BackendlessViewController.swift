//
//  BackendlessViewController.swift
//  FoodTracker
//
//  Created by Robert Martin on 9/21/16.
//  Copyright © 2016 Robert Martin. All rights reserved.
//

import UIKit

class BackendlessViewController: UIViewController {

    let EMAIL = "ios_user@gmail.com" // Doubles as User Name
    let PASSWORD = "password"
    
    let backendless = Backendless.sharedInstance()!
    
    class Comment: NSObject {
        
        var objectId: String?
        var message: String?
        var authorEmail: String?
        var topicId: Int = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func checkForBackendlessSetup() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.APP_ID == "<replace-with-your-app-id>" || appDelegate.SECRET_KEY == "<replace-with-your-secret-key>" {
            
            let alertController = UIAlertController(title: "Backendless Error",
                                                    message: "To use this sample you must register with Backendless, create an app, and replace the APP_ID and SECRET_KEY in the AppDelegate with the values from your app's settings.",
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func logInUser() {
        
        checkForBackendlessSetup()
        // First, check if the user is already logged in. If they are, we don't need to
        // ask them to login again.
        let isValidUser = backendless.userService.isValidUserToken()
        
        if isValidUser != nil && isValidUser != 0 {
            
            // The user has a valid user token so we know for sure the user is already logged!
            print("User is already logged: \(isValidUser?.boolValue)");
            
        } else {
            
            // If we were unable to find a valid user token, the user is not logged in and they'll
            // need to login. In a real app, this where we would send the user to a login screen to
            // collect their user name and password for the login attempt. For testing purposes,
            // we will simply login a test user using a hard coded user name and password.
            
            // Please note for a user to stay logged in, we had to make a call to
            // backendless.userService.setStayLoggedIn(true) and pass true.
            // This asks that the user should stay logged in by storing or caching the user's login
            // information so future logins can be skipped next time the user launches the app.
            // For this sample this call was made in the AppDelegate in didFinishLaunchingWithOptions.
            
            backendless.userService.login(EMAIL, password: PASSWORD,
                                           
                                           response: { (user: BackendlessUser?) -> Void in
                                            print("User logged in: \(user!.objectId)")
                },
                                           
                                           error: { (fault: Fault?) -> Void in
                                            print("User failed to login: \(fault)")
                }
            )
        }
        
        
    }
    
    func registerUser(){
        
        checkForBackendlessSetup()
        
        print( "registerBtn called!" )
        
        // In a real app, this where we would send the user to a register screen to collect their
        // user name and password for registering a new user. For testing purposes, we will simply
        // register a test user using a hard coded user name and password.
        let user: BackendlessUser = BackendlessUser()
        user.email = EMAIL as NSString!
        user.password = PASSWORD as NSString!
        
        backendless.userService.registering( user, response: { (user: BackendlessUser?) -> Void in
            print("User was registered: \(user?.objectId)")},
                                             error: { (fault: Fault?) -> Void in
                                                print("User failed to register: \(fault)")
            }
        )
        
    }
    
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0 ? true: false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
