//
//  DataService.swift
//  annoying-things
//
//  Created by Jon on 11/28/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//


// This is where we store references to Firebase (properties, routes, etc.)

import Foundation
import Firebase

let URL_BASE = "https://annoying-things.firebaseio.com"

class DataService {
    static let ds = DataService()
    
    // We're making a reference to our Firebase account
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
    
    
    //Creates a new user and passes in the new values
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}