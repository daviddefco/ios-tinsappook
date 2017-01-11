//
//  User.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 10/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import UIKit

class User {
    var objectID: String!
    var name: String!
    var email: String!
    var isFriend: Bool! = false
    var thumbnail: UIImage?
    
    var birthDate : Date?
    var gender: Bool?
    
    init(id: String, name: String, email: String, thumbnail: UIImage? = #imageLiteral(resourceName: "no-friend")) {
        self.objectID = id
        self.name = name
        self.email = email
    }
}
