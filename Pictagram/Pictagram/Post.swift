//
//  Post.swift
//  Pictagram
//
//  Created by Ethan Hess on 4/29/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    //private properties, then make public via computed properties
    
    private var _postDescription: String?
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: Firebase!
    
    var postDescription: String? {
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
    
    //initializer to write data
    
    init(description: String?, imageUrl: String?, username: String?) {
        
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    //initializer to read data with post identifier
    
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
        
        if let usernm = dictionary["username"] as? String {
            self._username = usernm
        }
        
        self._postRef = DataService.sharedInstance.REF_POSTS.childByAppendingPath(self._postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            
            _likes = _likes + 1
            
        } else {
            
            _likes = _likes - 1
        }
        
        //update likes on firebase 
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
        
    }

}