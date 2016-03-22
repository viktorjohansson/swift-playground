//
//  ExploreViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 19/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

@available(iOS 9.0, *)
class ExploreViewController: UIViewController, PostServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let postService = PostService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    
    func setPosts(json: AnyObject) {
        print(json)
    }
    
    func displayComments(comments: AnyObject) {
        print(comments)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let appleProducts = ["Utforska en skog", "Spill vatten på en hammare", "Cykla", "Spela en tennismatch", "Kör gokart"]
    
    let imageArray = [UIImage(named: "4"), UIImage(named: "1"), UIImage(named: "3"), UIImage(named: "2"), UIImage(named: "4") ]
    
    let commentsArray = [["Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt", "2", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt.", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt", "2", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt.", "Hejsan mitt namn är Viktor, vad heter du? Vart kommer du ifrån? Jag kommer ifrån Lessebo. Jag gillar att cykla väldigt långt"], ["test"], [], ["1"], [], ["1", "2", "3"], ["1", "2", "3", "4", "5", "6"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postService.getPosts()
        self.postService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.appleProducts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("exploreCell", forIndexPath: indexPath) as! CollectionViewCell
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "showLikes:")
        
        cell.likeCount.addGestureRecognizer(tapGesture)
        cell.imageView?.image = self.imageArray[indexPath.row]
        cell.label?.text = self.appleProducts[indexPath.row]
        cell.commentButton?.tag = indexPath.row
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let image = self.imageArray[indexPath.row]!
            let heightFactor = image.size.height / image.size.width
            let size = CGSize(width: screenSize.width, height: heightFactor * screenSize.width + 160)
            
            return size
    }
    
    @IBAction func pressCommentButton(sender: UIButton) {
        self.performSegueWithIdentifier("showCommentsFromExplore", sender: sender)
    }
    
    @IBAction func showLikes(sender: AnyObject?) {
        self.performSegueWithIdentifier("showLikesFromExplore", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCommentsFromExplore" {
            let vc = segue.destinationViewController as! NewViewController
            vc.comments = self.commentsArray[sender!.tag]
        }
        if segue.identifier == "showLikesFromExplore" {
        }
    }
    
    
    
}
