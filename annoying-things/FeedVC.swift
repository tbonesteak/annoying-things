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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

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
        
        //This will make the keyboard dismiss when taping outside the keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //This will make the keyboard dismiss when taping the return key.
        postField.delegate = self

        
        //The height of the cell with an image inside of it.
        tableView.estimatedRowHeight = 358
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // This observes any changes on a path, and gets called each time data changes and updates the UI.
        // Snapshots are the data objects you receive from Firebase. You have to parse snapshots to get the data out
        
        DataService.ds.REF_POSTS.queryOrderedByChild("timestamp").observeEventType(.Value, withBlock: { snapshot in
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
    
    //This will make the keyboard dismiss when taping outside the keyboard.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //This will make the keyboard dismiss when taping the return key.
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
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
                
                
                let urlStr = "https://pictshare.net/backend.php"
                let url = NSURL(string: urlStr)!
                let postimage: NSData = UIImageJPEGRepresentation(img, 0.2)!
                
                
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: postimage, name: "postimage", fileName:"postimage", mimeType: "image/jpg")
                    }) { encodingResult in
                        switch encodingResult {
                            //If it was successful, we're grabbing the JSON it sends back
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { request, response, result in
                                
                                print(result.value)
                                
                                if let info = result.value as? Dictionary<String, AnyObject> {
                                    
                                    if let imgLink = info["url"] as? String {
                                        print("LINK: \(imgLink)")
                                        self.postToFirebase(imgLink)
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
        
        func timeStamp() ->NSTimeInterval {
            let theTime = NSDate().timeIntervalSince1970
            return theTime
        }
        
        func timeDate() -> String {
            let theTimeDate = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            return theTimeDate
        }
        
        let myTimeStamp = timeStamp()
        let myTimeStampNeg = "-\(myTimeStamp)"
        let thedouble = Double(myTimeStampNeg)!
        
        let theTimeDate = timeDate()
        //////
        
        //Initializing a dictionary.
        var post: Dictionary<String, AnyObject> = [
            "description":  postField.text!,
            "likes": 0,
            // Here goes nothing again -JL
            "username": username,
            "timestamp": thedouble,
            "date": theTimeDate,
            "flags": 0
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