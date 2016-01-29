//
//  PostCell.swift
//  annoying-things
//
//  Created by Jon on 12/2/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var theUsername: UILabel!
    @IBOutlet weak var flagsImage: UIImageView!
    
    // Creating a container to hold the instance of the Post class
    var post: Post!
    //We're storing a request because we want to be able to cancel it. Normally you don't need to store to make a request.
    var request: Request?
    
    //Reference to whether the user has liked the current post that is being displayed
    var likeRef: Firebase!
    
    //-JL
    var yes: String!
    var flagsRef: Firebase!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //This is the code to make the heart icon recognize a tap.
        //likeTapped is a function we created below. The colon is necessary on likeTapped because it's going to pass an argument.
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
        let flagstap = UITapGestureRecognizer(target: self, action: "flagTapped:")
        flagstap.numberOfTapsRequired = 2
        flagsImage.addGestureRecognizer(flagstap)
        flagsImage.userInteractionEnabled = true

    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }


    func configureCell(post: Post, img: UIImage?) {
        
        // Passing in the instance of the Post class using the container we created at the top
        
        self.post = post
        
        //Grabbing a reference to the current user and the likes and the post key of the post being displayed on the screen.
        //If that post doesn't exist (meaning that post was never liked), that's ok too.
        likeRef = DataService.ds.REF_CURRENT_USER.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        flagsRef = DataService.ds.REF_CURRENT_USER.childByAppendingPath("flags").childByAppendingPath(post.postKey)
        
        // We're pulling out the attributes from the instance and throwing it into our outlets
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        //Here goes nothing. -JL ///////////
        
//        DataService.ds.REF_POSTS.observeEventType(FEventType.ChildAdded, withBlock: { snapshot in
//            self.yes = snapshot.value.objectForKey("username") as! String
//            self.theUsername.text = self.yes
//        })
        
        
        
        self.theUsername.text = post.username
        /////////////////////////
        
        //Checking to see if there is an image URL, because the user doesn't have to submit an image.
        if post.imageUrl != nil {
            
            //Now we need to either get the image from the cache, or download it.
            
            //We're passing in the cached image, if it exists.
            if img != nil {
                self.showcaseImg.image = img
                
                //We need this line or else the last image unintentionally doesn't display for some reason.
                self.showcaseImg.hidden = false
            } else {
                // If we're at this point, it means theres no image in the cache, so we need to make a download.
                //It's a GET request because we're downloading something, and its from the post.imageURL, and we are validating that it is of type image.
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err  in
                    
                    //If there was no error
                    if err == nil {
                        //We're passing in the image data
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        
                        //We need this line or else the last image unintentionally doesn't display for some reason.
                        self.showcaseImg.hidden = false
                        //Now that the image is downloaded, we're saving it to the cache.
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                    
                })
            }
            
        } else {
            
            //If the image doesn't exist, lets just hide it altogether.
            self.showcaseImg.hidden = true
        }
        
        
        
        
        flagsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let flagsDoNotExist = snapshot.value as? NSNull {
                self.flagsImage.image = UIImage(named: "clearflag1")
            } else {
                self.flagsImage.image = UIImage(named: "blackflag1")
            }
        })
        
        
        
        //This checks once to see if there is a like for the post.
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            //.Value grabs us the data. If it doesn't exist, we need to show the empty heart. In Firebase, data that doesn't exist is known as NSNull.
            if let doesNotExist = snapshot.value as? NSNull {
                //If we got here, it means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
        
    }
    
    func likeTapped(sender: UIGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            //.Value grabs us the data. If it doesn't exist, we need to show the empty heart. In Firebase, data that doesn't exist is known as NSNull.
            if let doesNotExist = snapshot.value as? NSNull {
                //If we got here, it means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true) //adds 1 to the likes.
                self.likeRef.setValue(true) //adds on a reference to the post that was liked to the current user.
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false) //removes 1 from the likes.
                self.likeRef.removeValue()
            }
        })
    }
    
    func flagTapped(sender: UIGestureRecognizer) {
        flagsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let flagsDoNotExist = snapshot.value as? NSNull {
                self.flagsImage.image = UIImage(named: "blackflag1")
                self.post.adjustFlags(true)
                self.flagsRef.setValue(true)
            } else {
                self.flagsImage.image = UIImage(named: "clearflag1")
                self.post.adjustFlags(false)
                self.flagsRef.removeValue()
            }
        })
    }

}
