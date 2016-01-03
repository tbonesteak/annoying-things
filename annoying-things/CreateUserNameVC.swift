//
//  CreateUserNameVC.swift
//  annoying-things
//
//  Created by Jon on 12/23/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

// -JL
import UIKit
import Firebase
import Alamofire


class CreateUserNameVC: UIViewController {
    
    @IBOutlet weak var createUsername: MaterialTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // We can use this to show any customized error pop message box.
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Alerts can have actions. In our case, we're gonna have an Ok button that closes it.
        // Handler is what happens after it closes. We don't want anything to happen.
        let action = UIAlertAction(title: "Got it", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func continueButton(sender: AnyObject) {
        
        if let txt = createUsername.text where txt != "" {
            
            var post: Dictionary<String, AnyObject> = [
                "username":  createUsername.text!
            ]
            
            DataService.ds.REF_CURRENT_USER.setValue(post)
            
            let username = createUsername.text
            NSUserDefaults.standardUserDefaults().setObject(username, forKey: KEY_USERNAME)
            performSegueWithIdentifier(TO_FEED_VC, sender: nil)
        }
        
    }
    

}
