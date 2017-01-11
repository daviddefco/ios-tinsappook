//
//  UserGenerator.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 13/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Parse

class UserGenerator: NSObject {
    
    static let instance = UserGenerator()
    
    let twentyYearsAgo = TimeInterval(-20 * 365 * 24 * 360)
    
    let maleUrls = [
        "Luismi" : "https://www.einforma.com/templates/web/_img/personajes/06/promo_producto.jpg",
        "Fabrizio" : "http://files.spazioweb.it/aruba91316/image/5-senales-de-que-eres-una-persona-sana-2.jpg",
        "Luis" : "http://conceptodefinicion.de/wp-content/uploads/2014/10/persona.jpg",
        "Lolo" : "http://sprites.comohacerpara.com/img/11882a-sintomas-persona-pesimista-negativa.jpg",
        "Angelo" : "http://gsewl-easypromos.netdna-ssl.com/groups/95/1095/thumb.large810.57ee2dad013c2.jpg"
    ]
    let femaleUrls = [
        "Lydia": "http://www.recursosdeautoayuda.com/wp-content/uploads/2013/10/persona_feliz.jpg",
        "Ely": "http://www.los40.com.co/images_remote/142/1425632_n_vir2.jpg",
        "Paula": "http://www.actitudfem.com/media/files/styles/large/public/images/2015/02/notagroserias.jpg?itok=oOZtumWb",
        "Rebeca" : "http://www.marketingguerrilla.es/wp-content/uploads/2013/06/gestos_negocio.jpg",
        "Claudia" : "http://www.revistamundonatural.com/fotos/persona.jpg"
    ]
    
    func generateBots() {
        let numberOfUsersQuery = PFUser.query()
        if (numberOfUsersQuery?.countObjects(nil))! < 5 {
            for (name, imageUrl) in maleUrls {
                createBot(name: name, imageUrl: imageUrl, gender: false)
            }
            for (name, imageUrl) in femaleUrls {
                createBot(name: name, imageUrl: imageUrl, gender: true)
            }
        }
    }
    
    func createBot(name: String, imageUrl: String, gender: Bool) {
        let user = PFUser()
        user.username = name.lowercased() + "@bot.com"
        user.email = user.username
        user.password = "bot12345"
        user["gender"] = false
        user["birthdate"] = Date(timeIntervalSinceNow: self.twentyYearsAgo)
        
        let acl = PFACL()
        acl.getPublicReadAccess = true
        acl.getPublicWriteAccess = true
        
        // User image
        let url = URL(string: imageUrl)
        do {
            let imageData = try Data(contentsOf: url!)
            user["imageFile"] = PFFile(name: "\(name).jpg", data: imageData)
            
            user.signUpInBackground(block: { (success, error) in
                if success {
                    print("Bot created successfully")
                }
            })
        } catch {
            print("could not retrieve URL image")
        }
    }
    
}
