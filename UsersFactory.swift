//
//  UsersFactory.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 24/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UsersFactory: NSObject {
    // Singleton: una única instancia y podré usarla en cualqeuir parte de la app
    static let instance = UsersFactory()
    
    // constante para declarar el nombre de la notificacion
    static let NOTIFICATION_NAME = NSNotification.Name(rawValue: "UsersLoaded")
    
    var currentUser : User?
    var users: [String: User] = [:]
    let anonymousUser = User(id: "000000000", name: "Unknown", email: "unknown")
    
    override init() {
        super.init()
        self.loadUsers()
        self.loadCurrentUser()
    }
    
    func loadUsers() {
        let query = PFUser.query()
        query?.findObjectsInBackground(block: { (results, error) in
            if error != nil {
                print ("Error en la recuperacion de usuarios \(error?.localizedDescription)")
            } else {
                self.users = [:] // Lo vaciamos por seguridad
                
                for result in results! {
                    if let user = result as? PFUser {
                        let defaultName = (user.username?.components(separatedBy: "@")[0])!.capitalized
                        let customName = user["nickname"] as? String
                        let myUser = User(
                            id: user.objectId!,
                            name: customName != nil ? customName! : defaultName,
                            email: user.email ?? ""
                        )
                        if let gender = user["gender"] as? Bool {
                            myUser.gender = gender
                        }
                        if let birthDate = user["birthdate"] as? Date{
                            myUser.birthDate = birthDate
                        }
                        if let imageFile = user["imageFile"] as? PFFile {
                            imageFile.getDataInBackground(block: { (imageData, error) in
                                if error != nil {
                                    print("Error \(error.debugDescription)")
                                    myUser.thumbnail = #imageLiteral(resourceName: "no-friend")
                                } else {
                                    let image = UIImage(data: imageData!)
                                    myUser.thumbnail = image
                                }
                            })
                        } else {
                            myUser.thumbnail = #imageLiteral(resourceName: "no-friend")
                        }

                        // Rellenado del campo de amistad en asíncrono
                        let query = PFQuery(className: "UserFriends")
                        query.whereKey("idUser", equalTo: (PFUser.current()?.objectId)!)
                        query.whereKey("idFriend", equalTo: user.objectId!)
                        
                        query.findObjectsInBackground { (results, error) in
                            if error != nil {
                                print("Error al recuperar la lista de amigos \(error?.localizedDescription)")
                            } else {
                                if let results = results {
                                    myUser.isFriend = results.count > 0
                                }
                            }
                        }
                        self.users[user.objectId!] = myUser
                    }
                }
                
                // Notificamos que los objetos han sido obtenidos
                NotificationCenter.default.post(name: UsersFactory.NOTIFICATION_NAME, object: nil)
            }
        })
    }
    
    func loadCurrentUser() {
        let pfUser = PFUser.current()!
        let objectId = pfUser.objectId!
        let email = pfUser.email!
        let defaultUserName = pfUser.username?.components(separatedBy: "@")[0]
        let customUserName = pfUser["nickname"] as? String
        
        self.currentUser = User(
            id: objectId,
            name: ((customUserName == nil) ? defaultUserName : customUserName)!,
            email: email
        )
        if let gender = pfUser["gender"] as? Bool {
            self.currentUser!.gender = gender
        }
        if let birthDate = pfUser["birthDate"] as? Date{
            self.currentUser!.birthDate = birthDate
        }

        if let imageFile = pfUser["imageFile"] as? PFFile {
            imageFile.getDataInBackground { (data, error) in
                if let data = data {
                    self.currentUser?.thumbnail = UIImage(data: data)
                }
            }
        }
    }
    
    func findUser(idUser: String) -> User? {
        return self.users[idUser]
    }
    
    func findUser(index: Int) -> User? {
        return Array(self.users.values)[index]
    }
    
    func findAllUsers() -> [User] {
        self.loadUsers()
        self.loadCurrentUser()
        return Array(self.users.values)
    }
    
    func findAllCandidateFriends() -> [User] {
        var friends: [String: User] = self.users
        friends.removeValue(forKey: (PFUser.current()?.objectId)!)
        return Array(friends.values)
    }
    
    func findFriends() -> [User] {
        var friends : [User] = []
        for user in Array(self.users.values) {
            if user.isFriend == true {
                friends.append(user)
            }
        }
        return friends
    }
    
    func getUnknownPeople() -> [User] {
        var unknownPeople : [User] = []
        for user in Array(self.users.values) {
            if !user.isFriend && user.objectID != self.currentUser?.objectID {
                unknownPeople.append(user)
            }
        }
        return unknownPeople
    }
    
    func anonymous() -> User {
        return self.anonymousUser
    }
    
    func stopBeingFriends(me idUser:String, exFriend idExFriend:String) {
        self.users[idExFriend]?.isFriend = false
        let query = PFQuery(className: "UserFriends")
        query.whereKey("idUser", equalTo: idUser)
        query.whereKey("idFriend", equalTo: idExFriend)
        query.findObjectsInBackground(block: { (results, error) in
            if error != nil {
                print("Error en la eliminación de la amistad \(error?.localizedDescription)")
            } else {
                if let results = results {
                    for result in results {
                        result.deleteInBackground()
                    }
                }
            }
        })
    }
}
