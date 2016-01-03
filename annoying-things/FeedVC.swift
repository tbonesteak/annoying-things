//
//  FeedVC.swift
//  annoying-things
//
//  Created by Jon on 12/2/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import Foundation

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    
    var posts = [Post]() // Empty array to contain our posts
    
    //We're setting the image selector to being empty from the start of the app.
    var imageSelected = false
    
    var imagePicker: UIImagePickerController!
    
    //-JL
    var username: String!
    
    static var imageCache = NSCache() //A container to hold our images that were downloaded. We're making it static to make it available globally.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //The height of the cell with an image inside of it.
        tableView.estimatedRowHeight = 358
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // This observes any changes on a path, and gets called each time data changes and updates the UI.
        // Snapshots are the data objects you receive from Firebase. You have to parse snapshots to get the data out
        
        DataService.ds.REF_POSTS.queryOrderedByPriority().observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            
            
            self.posts = [] // We want to empty out our array in case there's already data in it for everytime this updates
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    // Converting our objects to dictionaries
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post) //Adding posts to the array
                        
                        print("The key is \(key)")
                        print("The postDict is \(postDict)")
                    }
                    
                }
                
            }
            
            self.tableView.reloadData()
        })

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Grabbing all of our posts
        let post = posts[indexPath.row]
        
        //Grabbing a reuseable cell
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            //Since this is an old that went off the screen, we want to cancel the old request
            cell.request?.cancel()
            
            //Declaring an image variable and making it optional because it may not exist.
            var img: UIImage?
            
            //Grab the image URL if it exists.
            if let url = post.imageUrl {
                
                //We're storing the URL as the key name, and the image data is the value.
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            //Throwing our posts into the cells, and the img (if it exists)
            cell.configureCell(post, img: img)
            return cell
        } else {
            //If it didn't work, we're gonna return a new cell
            return PostCell()
        }

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //Grab our posts
        let post = posts[indexPath.row]
        
        //If no image exists, make it a shorter height.
        if post.imageUrl == nil {
            return 150
        } else {
            //If the image exists, make it the height that we set.
            return tableView.estimatedRowHeight
        }
    }
    
    //This is called after you pick an image.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        //Changing the image on our image selector to be whatever was picked from the user's image picker.
        imageSelectorImage.image = image
        //Setting our imageSelected boolean to true.
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        //Making sure the description field is not empty.
        if let txt = postField.text where txt != "" {
            
            //Checking to see if there is an image with two checks to make sure it's there.
            if let img = imageSelectorImage.image where imageSelected == true {
                
                //This is imageshack endpoint URL that we need to upload to.
                let urlStr = "https://post.imageshack.us/upload_api.php"
                //Taking the link and turning it into an NSURL.
                let url = NSURL(string: urlStr)!
                //Converting the image to data amd as a JPEG, and also compressing it. 0 means totally compressed, 1 means fully uncompressed.
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                //Imageshack API key, and converting it to data.
                let keyData = "P3Q08ZW98ea1d510dde3c37d688cdc0bd832ac05".dataUsingEncoding(NSUTF8StringEncoding)!
                //Converting the word JSON into data because it's a required parameter.
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                //We need to do a multiform data request because we are uploading several different things and of different file types (namely, the image file and the API key and format. So, we need to convert all of it to NSData.
                //In Alamofire, there is a method MultipartFormData, and this is what we are using for that purpose.
                //We're saying it's a POST request, it wants a URL so we're giving it that.
                //You can command click on upload to see what the requirements are.
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    //In this closure, we need to add the fields that the POST request is gonna require.
                    
                    //Passing in the image data and giving it the name "fileupload" as required from the API doc. fileName can be anything, so we're just calling it image for now, but Imageshack will rename that automatically. mimeType is the type of image we are transferring.
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName:"image", mimeType: "image/jpg")
                    //The API key. The name is "key" as required from the API doc.
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }) { encodingResult in
                        //After the POST request is made, the result is going to come through here. It will come back with either success or an error.
                        //We're doing a swtich statement in here
                        
                        //.Success and .Failure are part of Alamofire's multipartformdata.
                        switch encodingResult {
                        //If it was successful, we're grabbing the JSON it sends back
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { request, response, result in
                                
                                //We want to grab the image link out of the JSON. This is a dictionary within a dictionary.
                                //We're taking the value of the result we got back and converting it to a dictionary with keys of type string and values of type AnyObject.
                                if let info = result.value as? Dictionary<String, AnyObject> {
                                    
                                    //Grabbing the links dictionary that is contained within.
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        //Now grabbing the actual image link.
                                        if let imgLink = links["image_link"] as? String {
                                            print("LINK: \(imgLink)")
                                            //Calling the postToFirebase function and passing in the image link we grabbed from the returning JSON.
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                                
                            })
                        //If it fails, let's just print the error.
                        case .Failure(let error):
                            print (error)
                        }
            }
            
            } else {
                //If we're here it's because no image was selected. We're going to pass nothing in (nil).
                self.postToFirebase(nil)
            }
    }
   }
    
    func postToFirebase(imgUrl: String?) {
        
        //-JL
//            DataService.ds.REF_CURRENT_USER.observeEventType(FEventType.Value, withBlock: { snapshot in
//            self.username = snapshot.value.objectForKey("username") as! String
//            print("The user name is \(self.username)")
//        })

        username = NSUserDefaults.standardUserDefaults().valueForKey(KEY_USERNAME) as! String
        let date = NSDate().timeIntervalSince1970
        //////
        
        //Initializing a dictionary.
        var post: Dictionary<String, AnyObject> = [
            "description":  postField.text!,
            "likes": 0,
            // Here goes nothing again -JL
            "username": username,
            "time": date
        ]
        
        //If there is an image url, this will be added to the above dictionary.
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        //Here we are pushing the data into Firebase.
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        //Clearing out the text in the text box.
        postField.text = ""
        
        //Setting the image selector image back to the regular camera icon.
        imageSelectorImage.image = UIImage(named: "camera")
        
        //Setting out image selected boolean back to false.
        imageSelected = false
        tableView.reloadData()
    }
    
}
