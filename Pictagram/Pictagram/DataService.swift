//
//  DataService.swift
//  Pictagram
//
//  Created by Ethan Hess on 4/28/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://pictagram76.firebaseio.com"
let KEY_UID = "uid"

let LOGIN_SEGUE = "loggedIn"

//Firebase Status Codes
let STATUS_MISSING_CREDENTIALS = -5
let STATUS_ACCOUNT_DOESNTEXIST = -8


class DataService {
    
    static let sharedInstance = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: Firebase {
        
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        
        return user!
    }
    
    //add username ref. 
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}