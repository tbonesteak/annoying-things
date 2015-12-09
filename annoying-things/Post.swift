//
//  Post.swift
//  annoying-things
//
//  Created by Jon on 12/8/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import Foundation

// We don't want to be working with a bunch of dictionaries because it's a pain, so we're creating a class and storing the data in the class

class Post {
    private var _postDescription: String! //Description is required, so we use the !
    private var _imageUrl: String? //Images are optional, so we use the ?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!  // We're saving the unique identifier in case we to have access to it
    
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
        
        if let imgUrl = dictionary["imgUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
    }
}