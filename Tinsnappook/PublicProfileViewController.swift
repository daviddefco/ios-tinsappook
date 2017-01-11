//
//  PublicProfileViewController.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 3/1/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class PublicProfileViewController: UIViewController {

    var user: User?
    var posts: [Post] = []
    var query: PostsQuery?
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        
        if let image = user?.thumbnail {
            self.userImage.image = image
        } else {
            self.userImage.image = #imageLiteral(resourceName: "no-friend")
        }
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
        
        self.nameLabel.text = user?.name
        
        if let birthDate = user?.birthDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            self.birthDateLabel.text = "Born on \(formatter.string(from: birthDate))"
        } else {
            self.birthDateLabel.text = "Unknown birth date"
        }
        if let gender = user?.gender {
            gender == true ?
                self.friendButton.setImage(#imageLiteral(resourceName: "friend-female"), for: .normal)
                :self.friendButton.setImage(#imageLiteral(resourceName: "friend-male"), for: .normal)
        }
        
        self.query = PostsDAO.instance.getPosts(fromUser: (user?.objectID)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUserPosts), name: PostsQuery.NOTIFICATION_NAME, object: nil)
        self.query?.getResults()
    }
    
    func reloadUserPosts(notification: NSNotification) {
        if let notificationData = notification.userInfo as? [String: Post] {
            self.posts.append(notificationData["post"]!)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func friendsButtonClicked(_ sender: UIButton) {
        let currentUser = UsersFactory.instance.currentUser
        UsersFactory.instance.stopBeingFriends(me: (currentUser?.objectID)!, exFriend: (self.user?.objectID)!)
    }

    @IBAction func chatButtonClicked(_ sender: UIButton) {
    }

    @IBAction func locationButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
    }
    
    private func sendInformativeAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension PublicProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feedCell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        let post = self.posts[indexPath.row]
        if let userImage = post.postedBy.thumbnail {
            feedCell.userImage.image = userImage
        }
        feedCell.userName.text = post.postedBy.name
        feedCell.post.text = post.postContent
        feedCell.postDate.text = post.postDate
        feedCell.postImage.image = post.postImage
        return feedCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300;
    }
}
