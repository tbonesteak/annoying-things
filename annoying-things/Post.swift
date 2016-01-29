//
//  Post.swift
//  annoying-things
//
//  Created by Jon on 12/8/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import Foundation
import Firebase

// We don't want to be working with a bunch of dictionaries because it's a pain, so we're creating a class and storing the data in the class

class Post {
    private var _postDescription: String! //Description is required, so we use the !
    private var _imageUrl: String? //Images are optional, so we use the ?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!  // We're saving the unique identifier in case we to have access to it
    private var _postRef: Firebase! //A reference to the current post.
    private var _flags: Int!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    var flags: Int {
        return _flags
    }
    
    init(description: String, imageUrl: String?, username: String) {
       
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    // We use this initializer to convert the Firebase objects into dictionaries we can use
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        //-JL////////////////
        
        if let user = dictionary["username"] as? String {
            self._username = user
        }
        
        if let flags = dictionary["flags"] as? Int {
            self._flags = flags
        }
        //-JL////////////////
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
        
    }
    
    func adjustFlags(addFlag: Bool) {
        if addFlag {
            _flags = _flags + 1
        } else {
            _flags = _flags - 1
        }
        
        _postRef.childByAppendingPath("flags").setValue(_flags)
        
    }
}