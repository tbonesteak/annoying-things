//
//  ViewController.swift
//  annoying-things
//
//  Created by Jon on 11/20/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // when the app first loads, if they're already logged in, let's take them straight to the next screen
    // Segues dont work in viewDidLoad. They only work after the views have appeared on the screen.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Grab the key if it exists, and if so, take them to the next screen.
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
        
    }
    
    
    // Facebook Login button. This code is in the Firebase Facebook login documentation.
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            }  else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with Facebook. \(accessToken)")
                
                
                // We're telling Firebase that we want to work with Facebook, and we're giving
                // our access token
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    }   else {
                        print("Logged in! \(authData)")
                        
                        //Creates a new user who signed up with Facebook and saves into the Firebase database
                        let user = ["provider": authData.provider!, "blah":"test"]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        
                        // We're saving our newly created Firebase account and saving the UID to a key
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        
                        //After it saves the Firebase authentication token, we get sent to the next view controller
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                    
                })
                
            }
        }
    }
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            // The first thing we want to do is try to login.
            
            
            // authUser is used to login to Firebase with email and password.
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                
                if error != nil {
                    print(error)
                    
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        
                        // If it fails, it means the account doesn't exist, so we then create a new account, then log them in.
                        // We are creating a new user here.
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Please try again.")
                            } else {
                                // At this point, we've successfully created a new account, and now want to login.
                                // We want to save that user ID in the NSUserDefaults.
                                
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                                // We are creating the new user and saving it to the datbase here. We only get the AuthID after we have logged in.
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                    let user = ["provider": authData.provider!, "blah":"emailtest"]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                
                            }
                        })
                    }
                            // Wrong password error handling.
                            else {
                                    self.showErrorAlert("Could not login", msg: "Please check your username or password.")
                                }

                } else {
                    // If there is not an error, it means they've successfully logged in with an account they've created before
                    // and we're taking them to the next screen.
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID) //Note to self: This line was missing and causing a bug; without it, auto authentication will not work.
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
                
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
    }
    
    
    // We can use this to show any customized error pop message box.
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Alerts can have actions. In our case, we're gonna have an Ok button that closes it.
        // Handler is what happens after it closes. We don't want anything to happen.
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
        
    }

}

