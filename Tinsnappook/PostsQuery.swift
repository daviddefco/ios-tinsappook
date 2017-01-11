//
//  PostQuery.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 4/1/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Parse

class PostsQuery: NSObject {
    // constante para declarar el nombre de la notificacion
    static let NOTIFICATION_NAME = NSNotification.Name(rawValue: "PostRetrieved")
    
    private var query:PFQuery<PFObject>!
    
    init(query: PFQuery<PFObject>) {
        self.query = query
    }
    
    func getResults() {
        self.query.findObjectsInBackground { (results, error) in
            if error != nil {
                print("Error al recuperar la lista de posts \(error?.localizedDescription)")
            } else {
                for post in results! {
                    let imageFile = post["imageFile"] as! PFFile
                    imageFile.getDataInBackground(block: { (imageData, error) in
                        if error != nil {
                            print("Error al recuperar la imagen del post \(post.objectId)")
                        } else {
                            let image = UIImage(data: imageData!)
                            let postDate = post.updatedAt!
                            let postDateAsString = DateFormatter.localizedString(from: postDate, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.medium)
                            if let poster = UsersFactory.instance.findUser(idUser: post["idUser"] as! String) {
                                let myPost = Post(postedBy: poster, postDate: postDateAsString, postContent: post["message"] as! String, postImage: image!)
                                // Notificamos que los objetos han sido obtenidos
                                NotificationCenter.default.post(name: PostsQuery.NOTIFICATION_NAME, object: nil, userInfo: ["post": myPost])
                            }
                        }
                    })
                }
            }
        }
    }
}
