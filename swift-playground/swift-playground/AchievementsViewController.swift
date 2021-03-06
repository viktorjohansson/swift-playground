//
//  AchievementsViewController.swift
//  swift-playground
//
//  Created by viktor johansson on 19/03/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import MobileCoreServices


@available(iOS 9.0, *)
class AchievementsViewController: UIViewController, AchievementServiceDelegate, UploadServiceDelegate, UserServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Setup
    let achievementService = AchievementService()
    let uploadService = UploadService()
    let userService = UserService()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    let url = NSUserDefaults.standardUserDefaults().objectForKey("url")! as! String
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchField: UITextField!
    var uploadAchievementId: Int?
    
    let addToBucketlistImage = UIImage(named: "achievement_button_icon3")
    let removeFromBucketlistImage = UIImage(named: "bucketlist-remove_icon")
    let unlockedIcon = UIImage(named: "unlocked_icon")
    let lockedIcon = UIImage(named: "lock_icon")
    var noPostImage = UIImage(named: "post")
    var achievementCreatedAt: [String] = []
    var achievementUpdatedAt: [String] = []
    var achievementDescriptions: [String] = []
    var achievementIds: [Int] = []
    var achievementScores: [Int] = []
    var achievementCompleterCounts: [Int] = []
    var achievementFirstCompleterImages: [UIImage] = []
    var achievementSecondCompleterImages: [UIImage] = []
    var achievementThirdCompleterImages: [UIImage] = []
    var achievementFirstCompleterPostIds: [Int] = []
    var achievementSecondCompleterPostIds: [Int] = []
    var achievementThirdCompleterPostIds: [Int] = []
    var achievementInBucketlist: [Bool] = []
    var achievementCompleted: [Bool] = []
    var achievementCompletedPostIds: [Int] = []
    var moreAchievementsToLoad: Bool = true
    var segueShouldShowCompleters: Bool = false
    
    // MARK: Lifecycle
    func setAchievementData(json: AnyObject, firstFetch: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if json.count > 0 {
                for i in 0...(json.count - 1) {
                    self.achievementCreatedAt.append((json[i]?["created_at"])! as! String)
                    self.achievementUpdatedAt.append((json[i]?["updated_at"])! as! String)
                    self.achievementDescriptions.append((json[i]?["description"])! as! String)
                    self.achievementIds.append((json[i]?["id"]) as! Int)
                    self.achievementScores.append(json[i]?["score"] as! Int)
                    self.achievementCompleterCounts.append(json[i]?["posts_count"] as! Int)
                    self.achievementInBucketlist.append(json[i]?["bucketlist"] as! Bool)
                    self.achievementCompleted.append(json[i]?["completed"] as! Bool)
                    self.achievementCompletedPostIds.append(json[i]?["post_id"] as! Int)
                    let postImagesToLoad = json[i]["latest_posts"]!![0].count
                    // Load first three postes for achievement
                    if postImagesToLoad > 0 {
                        for postIndex in 0...(postImagesToLoad - 1) {
                            if let completerImageUrl = ((json[i]["latest_posts"] as! NSArray)[0] as! NSArray)[postIndex] as? String {
                                let url = NSURL(string: self.url + completerImageUrl)!
                                let data = NSData(contentsOfURL:url)
                                if data != nil {
                                    switch postIndex {
                                    case 0:
                                        self.achievementFirstCompleterImages.append(UIImage(data: data!)!)
                                        self.achievementFirstCompleterPostIds.append(((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int)
                                    case 1:
                                        self.achievementSecondCompleterImages.append(UIImage(data: data!)!)
                                        self.achievementSecondCompleterPostIds.append(((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int)
                                    case 2:
                                        self.achievementThirdCompleterImages.append(UIImage(data: data!)!)
                                        self.achievementThirdCompleterPostIds.append(((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int)
                                    default:
                                        print("Switch Error")
                                    }
                                }
                            }
                        }
                    }
                    var postsAlreadyLoaded = postImagesToLoad
                    while postsAlreadyLoaded < 3 {
                        switch postsAlreadyLoaded {
                        case 0:
                            self.achievementFirstCompleterImages.append(self.noPostImage!)
                            self.achievementFirstCompleterPostIds.append(0)
                        case 1:
                            self.achievementSecondCompleterImages.append(self.noPostImage!)
                            self.achievementSecondCompleterPostIds.append(0)
                        case 2:
                            self.achievementThirdCompleterImages.append(self.noPostImage!)
                            self.achievementThirdCompleterPostIds.append(0)
                        default:
                            print("Switch Error")
                        }
                        postsAlreadyLoaded! += 1
                    }
                }
            } else {
                self.moreAchievementsToLoad = false
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(self.collectionView.reloadData)
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.removeIndicators()
            }
        })
    }
    
    func updateAchievementsData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                if let achievementId = json[i]?["id"] as? Int {
                if let cellIndex = achievementIds.indexOf({$0 == achievementId}) {
                    achievementScores[cellIndex] = json[i]?["score"] as! Int
                    achievementUpdatedAt[cellIndex] = json[i]?["updated_at"] as! String
                    achievementCompleterCounts[cellIndex] = json[i]?["posts_count"] as! Int
                    achievementInBucketlist[cellIndex] = json[i]?["bucketlist"] as! Bool
                    achievementCompleted[cellIndex] = json[i]?["completed"] as! Bool
                    achievementCompletedPostIds[cellIndex] = json[i]?["post_id"] as! Int
                    let postImagesToLoad = json[i]["latest_posts"]!![0].count
                    if postImagesToLoad > 0 {
                        for postIndex in 0...(postImagesToLoad - 1) {
                            if let completerImageUrl = ((json[i]["latest_posts"] as! NSArray)[0] as! NSArray)[postIndex] as? String {
                                let url = NSURL(string: self.url + completerImageUrl)!
                                let data = NSData(contentsOfURL:url)
                                if data != nil {
                                    switch postIndex {
                                    case 0:
                                        achievementFirstCompleterImages[cellIndex] = UIImage(data: data!)!
                                        achievementFirstCompleterPostIds[cellIndex] = ((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int
                                    case 1:
                                        achievementSecondCompleterImages[cellIndex] = UIImage(data: data!)!
                                        achievementSecondCompleterPostIds[cellIndex] = ((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int
                                    case 2:
                                        achievementThirdCompleterImages[cellIndex] = UIImage(data: data!)!
                                        achievementThirdCompleterPostIds[cellIndex] = ((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int
                                    default:
                                        print("Switch Error")
                                    }
                                }
                            }
                        }
                    }
                    var postsAlreadyLoaded = postImagesToLoad
                    while postsAlreadyLoaded < 3 {
                        switch postsAlreadyLoaded {
                        case 0:
                            achievementFirstCompleterImages[cellIndex] = noPostImage!
                            achievementFirstCompleterPostIds[cellIndex] = 0
                        case 1:
                            achievementSecondCompleterImages[cellIndex] = noPostImage!
                            achievementSecondCompleterPostIds[cellIndex] = 0
                        case 2:
                            achievementThirdCompleterImages[cellIndex] = noPostImage!
                            achievementThirdCompleterPostIds[cellIndex] = 0
                        default:
                            print("Switch Error")
                        }
                        postsAlreadyLoaded! += 1
                    }

                }
                
                } else {
                    reloadAchievements()
                    break
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
        }
    }
    
    func setNewAchievementData(json: AnyObject) {
        if json.count > 0 {
            for i in 0...(json.count - 1) {
                achievementCreatedAt.insert(((json[i]?["created_at"])! as! String), atIndex: 0)
                achievementUpdatedAt.insert(((json[i]?["updated_at"])! as! String), atIndex: 0)
                achievementDescriptions.insert(((json[i]?["description"])! as! String), atIndex: 0)
                achievementIds.insert(((json[i]?["id"]) as! Int), atIndex: 0)
                achievementScores.insert((json[i]?["score"] as! Int), atIndex: 0)
                achievementCompleterCounts.insert((json[i]?["posts_count"] as! Int), atIndex: 0)
                achievementInBucketlist.insert((json[i]?["bucketlist"] as! Bool), atIndex: 0)
                achievementCompleted.insert((json[i]?["completed"] as! Bool), atIndex: 0)
                achievementCompletedPostIds.insert((json[i]?["post_id"] as! Int), atIndex: 0)
                let postImagesToLoad = json[i]["latest_posts"]!![0].count
                // Load first three postes for achievement
                if postImagesToLoad > 0 {
                    for postIndex in 0...(postImagesToLoad - 1) {
                        if let completerImageUrl = ((json[i]["latest_posts"] as! NSArray)[0] as! NSArray)[postIndex] as? String {
                            let url = NSURL(string: self.url + completerImageUrl)!
                            let data = NSData(contentsOfURL:url)
                            if data != nil {
                                switch postIndex {
                                case 0:
                                    achievementFirstCompleterImages.insert((UIImage(data: data!)!), atIndex: 0)
                                    achievementFirstCompleterPostIds.insert(((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int, atIndex: 0)
                                case 1:
                                    achievementSecondCompleterImages.insert((UIImage(data: data!)!), atIndex: 0)
                                    achievementSecondCompleterPostIds.insert(((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int, atIndex: 0)
                                case 2:
                                    achievementThirdCompleterImages.insert((UIImage(data: data!)!), atIndex: 0)
                                    achievementThirdCompleterPostIds.insert(((json[i]["latest_posts"] as! NSArray)[1] as! NSArray)[postIndex] as! Int, atIndex: 0)
                                default:
                                    print("Switch Error")
                                }
                            }
                        }
                    }
                }
                var postsAlreadyLoaded = postImagesToLoad
                while postsAlreadyLoaded < 3 {
                    switch postsAlreadyLoaded {
                    case 0:
                        achievementFirstCompleterImages.insert((noPostImage!), atIndex: 0)
                        achievementFirstCompleterPostIds.insert(0, atIndex: 0)
                    case 1:
                        achievementSecondCompleterImages.insert((noPostImage!), atIndex: 0)
                        achievementSecondCompleterPostIds.insert(0, atIndex: 0)
                    case 2:
                        achievementThirdCompleterImages.insert((noPostImage!), atIndex: 0)
                        achievementThirdCompleterPostIds.insert(0, atIndex: 0)
                    default:
                        print("Switch Error")
                    }
                    postsAlreadyLoaded! += 1
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
            collectionView.setContentOffset(CGPointMake(0, -collectionView.contentInset.top), animated:true)
        }
    }
    
    func setUploadedResult(json: AnyObject) {
        SwiftOverlays.removeAllBlockingOverlays()
        let postId = json["id"] as! Int
        self.performSegueWithIdentifier("showPostFromAchievements", sender: postId)
    }
    
    func loadMore(cellIndex: Int) {
        if cellIndex == self.achievementDescriptions.count - 1 && moreAchievementsToLoad {
            collectionView.loadIndicatorBottom()
            achievementService.fetchMoreAchievements(achievementIds.last!)
        }
    }
    
    func setUserData(json: AnyObject, follow: Bool) {}
    func updateUserData(json: AnyObject) {}
    func setNoticeData(notSeenNoticeCount: Int) {
        if notSeenNoticeCount > 0 {
            self.tabBarController?.tabBar.items?.last?.badgeValue = "\(Int(notSeenNoticeCount))"
        } else {
            self.tabBarController?.tabBar.items?.last?.badgeValue = nil
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        achievementService.getAchievements()
        searchField.layer.frame = CGRectMake(0 , 0, screenSize.width - 80, 30)
        self.achievementService.delegate = self
        self.uploadService.delegate = self
        self.userService.delegate = self
        self.collectionView.delegate = self
        collectionView.loadIndicatorMid(screenSize, style: UIActivityIndicatorViewStyle.White)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnSwipe = true
        userService.getNotSeenNoticeCount()
        achievementService.updateAchievements(achievementIds, updatedAt: achievementUpdatedAt)
        if achievementIds.first != nil {
            achievementService.getNewAchievements(achievementIds.first!)
        }
        NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.achievementDescriptions.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        loadMore(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("achievementCell", forIndexPath: indexPath) as! AchievementCollectionViewCell
        
        let achievementTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAchievement(_:)))
        
        let firstCompleterImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showFirstCompleter(_:)))
        let secondCompleterImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showSecondCompleter(_:)))
        let thirdCompleterImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(showThirdCompleter(_:)))
        
        cell.tag = indexPath.row
        cell.achievementImage1.addGestureRecognizer(firstCompleterImageTapGesture)
        cell.achievementImage2.addGestureRecognizer(secondCompleterImageTapGesture)
        cell.achievementImage3.addGestureRecognizer(thirdCompleterImageTapGesture)
        cell.achievementLabel.addGestureRecognizer(achievementTapGesture)
        
        cell.achievementImage1.image = achievementFirstCompleterImages[indexPath.row]
        cell.achievementImage2.image = achievementSecondCompleterImages[indexPath.row]
        cell.achievementImage3.image = achievementThirdCompleterImages[indexPath.row]
        cell.completersLabel.text! = "\(achievementCompleterCounts[indexPath.row]) har klarat detta"
        cell.achievementLabel.text! = achievementDescriptions[indexPath.row]
        cell.scoreLabel.text! = "\(achievementScores[indexPath.row])p"
        if achievementInBucketlist[indexPath.row] {
            cell.bucketlistButton.setImage(removeFromBucketlistImage, forState: .Normal)
        } else {
            cell.bucketlistButton.setImage(addToBucketlistImage, forState: .Normal)
        }
        if achievementCompleted[indexPath.row] {
            cell.lockImage.image = unlockedIcon
            cell.uploadButton.setTitle("Visa mitt inlägg", forState: .Normal)
        } else {
            cell.lockImage.image = lockedIcon
            cell.uploadButton.setTitle(("Ladda upp"), forState: .Normal)
        }
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.uploadButton.layer.cornerRadius = 5
        cell.uploadButton.tag = indexPath.row
        cell.shareButton.tag = indexPath.row
        cell.completersButton.tag = indexPath.row
        cell.bucketlistButton.tag = indexPath.row
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height = CGFloat(320)
        if screenSize.width > height {
            height = screenSize.width * 0.9
        }
        let size = CGSize(width: screenSize.width, height: height)
            
        return size
    }
    
    // MARK: User Interaction
    @IBAction func showCompleters(sender: AnyObject?) {
        self.segueShouldShowCompleters = true
        self.performSegueWithIdentifier("showLikesViewFromAchievement", sender: sender!.tag)
    }
    
    @IBAction func shareAchievement(sender: AnyObject?) {
        self.segueShouldShowCompleters = false
        self.performSegueWithIdentifier("showLikesViewFromAchievement", sender: sender!.tag)
    }
    
    @IBAction func showAchievement(sender: AnyObject?) {
        self.performSegueWithIdentifier("showAchievementFromAchievements", sender: sender)
    }
    
    @IBAction func showSearch(sender: AnyObject) {
        self.performSegueWithIdentifier("showSearchFromAchievements", sender: sender)
    }
    
    @IBAction func bucketlistPress(sender: AnyObject?) {
        let cellIndex = sender!.tag
        let indexPath = NSIndexPath(forItem: cellIndex, inSection: 0)
        let thisCell = collectionView.cellForItemAtIndexPath(indexPath) as! AchievementCollectionViewCell
        if achievementCompleted[cellIndex] {
            let ac = UIAlertController(title: "Avklarat uppdrag", message: "Du har redan klarat detta uppdrag och kan därför inte lägga till det i din lista", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            if thisCell.bucketlistButton.currentImage == addToBucketlistImage {
                achievementService.addToBucketlist(achievementIds[cellIndex])
                thisCell.bucketlistButton.setImage(removeFromBucketlistImage, forState: .Normal)
            } else {
                achievementService.removeFromBucketlist(achievementIds[cellIndex])
                thisCell.bucketlistButton.setImage(addToBucketlistImage, forState: .Normal)
            }
        }
    }
    
    @IBAction func uploadPost(sender: AnyObject?) {
        uploadAchievementId = achievementIds[sender!.tag]
        if achievementCompleted[sender!.tag] {
            self.performSegueWithIdentifier("showPostFromAchievements", sender: achievementCompletedPostIds[sender!.tag])
        } else {
            let existingOrNewMediaController = UIAlertController(title: "Inlägg", message: "Välj från bibliotek eller ta bild", preferredStyle: .Alert)
            existingOrNewMediaController.addAction(UIAlertAction(title: "Välj från bibliotek", style: .Default) { (UIAlertAction) in
                self.useLibrary()
                })
            existingOrNewMediaController.addAction(UIAlertAction(title: "Ta bild eller video", style: .Default) { (UIAlertAction) in
                self.useCamera()
                })
            existingOrNewMediaController.addAction(UIAlertAction(title: "Avbryt", style: .Cancel, handler: nil))
            self.presentViewController(existingOrNewMediaController, animated: true, completion: nil)
        }
    }
    
    func showFirstCompleter(sender: AnyObject?) {
        let point = sender?.view.superview!.superview!.superview
        let thisCell: AchievementCollectionViewCell = point as! AchievementCollectionViewCell
        let cellIndex = thisCell.tag
        let postId = achievementFirstCompleterPostIds[cellIndex]
        if postId != 0 {
            self.performSegueWithIdentifier("showPostFromAchievements", sender: postId)
        }
    }
    
    func showSecondCompleter(sender: AnyObject?) {
        let point = sender?.view.superview!.superview!.superview
        let thisCell: AchievementCollectionViewCell = point as! AchievementCollectionViewCell
        let cellIndex = thisCell.tag
        let postId = achievementSecondCompleterPostIds[cellIndex]
        if postId != 0 {
            self.performSegueWithIdentifier("showPostFromAchievements", sender: postId)
        }
    }
    
    func showThirdCompleter(sender: AnyObject?) {
        let point = sender?.view.superview!.superview!.superview
        let thisCell: AchievementCollectionViewCell = point as! AchievementCollectionViewCell
        let cellIndex = thisCell.tag
        let postId = achievementThirdCompleterPostIds[cellIndex]
        if postId != 0 {
            self.performSegueWithIdentifier("showPostFromAchievements", sender: postId)
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var cellIndex: Int = 0
        if sender?.integerValue != nil {
            // Uploaded post, send to specific post, this should be changed for better readability.
            if segue.identifier == "showLikesViewFromAchievement" {
                let vc = segue.destinationViewController as! LikesViewController
                vc.achievementId = achievementIds[sender!.integerValue]
                if segueShouldShowCompleters {
                    vc.typeIs = "achievementCompleters"
                } else {
                    vc.typeIs = "achievementShare"
                }
            } else {
                let vc = segue.destinationViewController as! ShowPostViewController
                vc.postId = sender?.integerValue
            }
        } else {
            let point = sender?.view
            let mainCell = point?.superview
            let main = mainCell?.superview
            if let thisCell: AchievementCollectionViewCell = main as? AchievementCollectionViewCell {
                cellIndex = thisCell.tag
            }
            
            if segue.identifier == "showAchievementFromAchievements" {
                let vc = segue.destinationViewController as! ShowAchievementViewController
                vc.achievementId = achievementIds[cellIndex]
            }
        }
    }
    
    // MARK: Additional Helpers
    func useLibrary() {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        imageFromSource.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imageFromSource.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }
    
    func useCamera() {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        imageFromSource.sourceType = UIImagePickerControllerSourceType.Camera
        imageFromSource.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        self.presentViewController(imageFromSource, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType]
        if mediaType!.isEqualToString(kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            let fixedImage = image?.fixOrientation()
            let imageData: NSData = UIImageJPEGRepresentation(fixedImage!, 0.1)!
            let pngImage = UIImagePNGRepresentation(UIImage(data: imageData)!)
            uploadService.uploadImage(pngImage!, achievementId: uploadAchievementId!)
        } else if mediaType!.isEqualToString(kUTTypeMovie as String) {
            let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL)!
            uploadService.uploadVideo(pickedVideo, achievementId: uploadAchievementId!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        SwiftOverlays.showBlockingWaitOverlayWithText("Laddar upp...")
    }
    
    func reloadAchievements() {
        achievementCreatedAt = []
        achievementUpdatedAt = []
        achievementDescriptions = []
        achievementIds = []
        achievementScores = []
        achievementCompleterCounts = []
        achievementFirstCompleterImages = []
        achievementSecondCompleterImages = []
        achievementThirdCompleterImages = []
        achievementFirstCompleterPostIds = []
        achievementSecondCompleterPostIds = []
        achievementThirdCompleterPostIds = []
        achievementInBucketlist = []
        achievementCompleted = []
        achievementCompletedPostIds = []
        moreAchievementsToLoad = true
        segueShouldShowCompleters = false
        achievementService.getAchievements()
    }
    
}
