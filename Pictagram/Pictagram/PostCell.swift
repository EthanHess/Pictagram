//
//  PostCell.swift
//  Pictagram
//
//  Created by Ethan Hess on 4/29/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var appImg: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!

    var request: Request?
    var likeRef: Firebase!
    
    private var _post: Post?
    
    var post: Post? {
        return _post
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func drawRect(rect: CGRect) {
        
        userImg.layer.cornerRadius = userImg.frame.size.width / 2
        userImg.clipsToBounds = true
        appImg.clipsToBounds = true
        likeButton.layer.cornerRadius = likeButton.frame.size.width / 2
        likeButton.clipsToBounds = true
        
    }
    
    func configureCellWithPost(post: Post, image: UIImage?) {
        
        self.appImg.image = nil
        self._post = post
        self.likeRef = DataService.sharedInstance.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        if let desc = post.postDescription where post.postDescription != "" {
            self.descriptionText.text = desc
        } else {
            self.descriptionText.hidden = true
        }
        
        self.likesLabel.text = "\(post.likes)"
        
        if let usrnm = post.username as? String {
            usernameLabel.text = usrnm
        }
        
        if post.imageUrl != nil {
            
            //Use the cached image if there is one, otherwise download the image
            if image != nil {
                appImg.image = image!
            } else {
                
                //Must store the request so we can cancel it later if this cell is now out of the users view
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        
                        if let img = UIImage(data: (data)!) {
                        
                            self.appImg.image = img
                            
                            if image != nil {
                        
                            FeedViewController.imageCache.setObject(image!, forKey: self.post!.imageUrl!)
                                
                            }
                            
                        }
                    }
                })
            }
            
        } else {
            self.appImg.hidden = true
        }
        
        
        //Grab the current users likes and see if the current post has been liked
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeButton.setBackgroundImage(UIImage(named: "heart-empty"), forState: UIControlState.Normal)
            } else {
                self.likeButton.setBackgroundImage(UIImage(named: "heart-full"), forState: UIControlState.Normal)
            }
        })
        
    }
    
    @IBAction func likeTapped() {
        
        //change button according to whether user likes or unlikes
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeRef.setValue(true)
                self.likeButton.setBackgroundImage(UIImage(named: "heart-empty"), forState: UIControlState.Normal)
                self.post!.adjustLikes(true)
                
            } else {
                self.likeRef.removeValue()
                self.likeButton.setBackgroundImage(UIImage(named: "heart-full"), forState: UIControlState.Normal)
                self.post!.adjustLikes(false)
            }
            
            self.likesLabel.text = "\(self.post!.likes)"
        })
        
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
