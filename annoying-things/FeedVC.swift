//
//  FeedVC.swift
//  annoying-things
//
//  Created by Jon on 12/2/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    
    var posts = [Post]() // Empty array to contain our posts
    
    var imagePicker: UIImagePickerController!
    
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
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
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
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
    }
    
    
}
