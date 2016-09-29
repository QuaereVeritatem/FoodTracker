//
//  SettingsViewController.swift
//  
//
//  Created by Robert Martin on 9/29/16.
//
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIButton) {
    
        spinner.startAnimating()
        
        BackendlessManager.sharedInstance.logoutUser(
            completion: {
                
                self.spinner.stopAnimating()
                
                self.performSegue(withIdentifier: "gotoLoginFromMealTable", sender: sender)
            },
            
            error: { message in
                
                self.spinner.stopAnimating()
                
                Utility.showAlert(viewController: self, title: "Logout Error", message: message)
        })

    
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
