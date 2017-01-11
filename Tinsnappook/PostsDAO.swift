//
//  PostDAO.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 4/1/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Parse

class PostsDAO: NSObject {

    // Singleton: una única instancia y podré usarla en cualquier parte de la app
    static let instance = PostsDAO()
    
    func getPosts(notFromUser userId:String) -> PostsQuery {
        let query = PFQuery(className: "Post")
        query.whereKey("idUser", notEqualTo: userId)
        query.order(byDescending: "createdAt")
        let postQuery = PostsQuery(query: query)
        return postQuery
    }
    
    func getPosts(fromUser userId:String) -> PostsQuery {
        let query = PFQuery(className: "Post")
        query.whereKey("idUser", equalTo: userId)
        query.order(byDescending: "createdAt")
        let postQuery = PostsQuery(query: query)
        return postQuery
    }
}
