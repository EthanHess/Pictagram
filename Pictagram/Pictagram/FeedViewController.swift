//
//  FeedViewController.swift
//  Pictagram
//
//  Created by Ethan Hess on 4/25/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    static let imageCache = NSCache()
    
    //TODO: Subclass/ make custom
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postField: UITextField!
    
    var chosenImage : UIImage?
    
    var posts = [Post]()
    var imagePickerController: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 400

        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        initializeDataObservation()
    }
    
    func initializeDataObservation() {
        
        DataService.sharedInstance.REF_POSTS.observeEventType(.Value, withBlock: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                //clear the array
                self.posts = []
                
                for snap in snapshots {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        //identifier
                        let key = snap.key
                        
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                        
                    }
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? PostCell {
            
            //when cell is recycled cancel Alamofire request to stop downloading image for said index path 
            
            cell.request?.cancel()
            
            let post = self.posts[indexPath.row]
            
            var postImage : UIImage?
            
            if let url = post.imageUrl {
                
                postImage = FeedViewController.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCellWithPost(post, image: postImage)
            
            return cell
        }
        
        else {
            
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = self.posts[indexPath.row]
        
        if post.imageUrl == nil {
            
            return 150
        }
        
        else {
            
            //set at 400
            return tableView.estimatedRowHeight
        }
    }
    
    //hook up to button
    @IBAction func selectImage(sender: AnyObject) {
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        if let comment = postField.text where comment != "" {
            
            if let image = chosenImage {
                
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(image, 0.2)!
                
                let keyData = "49ACILMSa3bb4f31c5b6f7aeee9e5623c70c83d7".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                //upload image data to image shack server 
                
                Alamofire.upload(.POST, url, multipartFormData: { (multipartFormData) in
                    
                    multipartFormData.appendBodyPart(data: imgData, name:"fileupload", fileName:"image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }, encodingCompletion: { encodingResult in
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            
                            upload.responseJSON(completionHandler: { response in
                                
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        print(links)
                                        if let imgLink = links["image_link"] as? String {
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                            
                        case .Failure(let error):
                            
                            print(error)
                            
                            //add alert with retry button
                        }
                })

            } else {
                postToFirebase(nil)
            }

        }
    }
    
    func postToFirebase(imageURL: String?) {
        
        var post: Dictionary<String, AnyObject> = [
            "description":postField.text!,
            "likes": 0
        ]
        
        if imageURL != nil {
            post["imageUrl"] = imageURL!
        }
        
        //Save new post to firebase
        let fbPost = DataService.sharedInstance.REF_POSTS.childByAutoId()
        fbPost.setValue(post)
        
        //Clear out fields
        self.postField.text = ""
        
        
        tableView.reloadData()
        
    }
    
    //image picker delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
        chosenImage = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
