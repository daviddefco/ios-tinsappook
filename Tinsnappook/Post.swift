//
//  Post.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 17/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

class Post: NSObject {
    var postedBy: User!
    var postDate: String!
    var postContent: String!
    var postImage: UIImage!
    
    init(postedBy: User, postDate: String, postContent: String, postImage: UIImage) {
        self.postedBy = postedBy
        self.postDate = postDate
        self.postContent = postContent
        self.postImage = postImage
    }
}
