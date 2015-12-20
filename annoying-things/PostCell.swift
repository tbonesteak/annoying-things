//
//  PostCell.swift
//  annoying-things
//
//  Created by Jon on 12/2/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    // Creating a container to hold the instance of the Post class
    var post: Post!
    //We're storing a request because we want to be able to cancel it. Normally you don't need to store to make a request.
    var request: Request?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }


    func configureCell(post: Post, img: UIImage?) {
        
        // Passing in the instance of the Post class using the container we created at the top
        
        self.post = post
        
        // We're pulling out the attributes from the instance and throwing it into our outlets
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
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
        
    }

}
