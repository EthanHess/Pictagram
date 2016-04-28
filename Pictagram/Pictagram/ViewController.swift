//
//  ViewController.swift
//  Pictagram
//
//  Created by Ethan Hess on 4/25/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {
    
    //add textField delegate
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(LOGIN_SEGUE, sender: nil)
        }
    }
    
    @IBAction func tryLogin(sender: UIButton!) {
    
        if let email = emailField.text where email != "", let password = passwordField.text where password != "" {
            
            DataService.sharedInstance.REF_BASE.authUser(email, password: password, withCompletionBlock: { (error, authData) in
                
                if error != nil {
                    print(error.code)
                    
                    //firebase error codes
                    
                    if error.code == STATUS_ACCOUNT_DOESNTEXIST {
                        
                        DataService.sharedInstance.REF_BASE.createUser(email, password: password, withValueCompletionBlock: { (error, result) in
                            
                            if error != nil {
                                
                                self.showErrorAlert("Could not create account", message: "Problem creating account. Try something else")
                                
                            } else {
                                //save uid to defaults
                                let uid = result["uid"] as? String
                                NSUserDefaults.standardUserDefaults().setValue(uid, forKey: KEY_UID)
                                
                                DataService.sharedInstance.REF_BASE.authUser(email, password: password, withCompletionBlock: { (error, data) in
                                    
                                    //store account type
                                    let user = ["provider": authData.provider!]
                                    DataService.sharedInstance.createFirebaseUser(uid!, user: user)
                                })
                                
                                self.performSegueWithIdentifier("loggedIn", sender: nil)
                            }
                        })
                        
                    } else {
                        self.showErrorAlert("Error loggin in", message: "Could not log in. Check your username and password")
                    }
                    
                } else {
                    
                    self.performSegueWithIdentifier("loggedIn", sender: nil)
                }
            })
            
        }
            
        else {
            showErrorAlert("Email & Password Required", message: "You must enter an email address and a password")
        }
    }
    
    @IBAction func facebookButtonPressed(sender: UIButton!) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) in
            
            if error != nil {
                print(error.localizedDescription)
            }
            
            else {
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                DataService.sharedInstance.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (error, authData) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged In! \(authData)")
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        
                        //Store what type of account this is
                        let user = ["provider": authData.provider!]
                        DataService.sharedInstance.createFirebaseUser(authData.uid, user: user)
                        
                        self.performSegueWithIdentifier("loggedIn", sender: nil)
                    }
                })
            }
        }
    }
    
    func showErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

