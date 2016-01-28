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


class CreateUserNameVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var createUsername: MaterialTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This will make the keyboard dismiss when taping outside the keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //This will make the keyboard dismiss when taping the return key.
        createUsername.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //This will make the keyboard dismiss when taping outside the keyboard.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //This will make the keyboard dismiss when taping the return key.
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
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
            performSegueWithIdentifier(TO_TERMS_VC, sender: nil)
        } else {
            showErrorAlert("Username is required", msg: "Please enter a user name. Thank you very much!")
        }
        
    }
    

}
