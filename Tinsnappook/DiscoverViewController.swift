//
//  DiscoverViewController.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 10/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class DiscoverViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    var users : [User] = []
    var userIndex = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            // Si hemos sido revelados por el controlador del Reveal lo usamos a el como controlador en lugar de
            // ser nosotoros los que gestionemos
            self.menuButton.target = self.revealViewController()
            // Acción del selector
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            // Añadimos el reconocedor del gesto de swipe para que la barra de navegación aparezca progresivamente al arrastrar
            // y no solo al pulsar el botón de menú
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        users = UsersFactory.instance.getUnknownPeople()
        self.reloadView()
        
        // Añadimos un gesture recognizer para que se pueda arrastrar la imagen
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DiscoverViewController.imageDragged(gestureRecognizer:)))
        self.userImage.isUserInteractionEnabled = true
        self.userImage.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadView() {
        if (users.count > 0) {
            userIndex += 1
            if userIndex >= self.users.count {
                userIndex = 0
            }
            let user = users[userIndex]
            self.userName.text = user.name
            if let thumbnail = user.thumbnail {
                self.userImage.image = thumbnail
            } else {
                self.userImage.image = #imageLiteral(resourceName: "no-friend")
            }
        } else {
            self.userName.text = nil
            self.userImage.isUserInteractionEnabled = false
            self.userImage.image = nil
        }
    }

    func imageDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        let imageView = gestureRecognizer.view!
        imageView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let rotationAngle = (imageView.center.x - self.view.bounds.width / 2) / 180
        var rotation = CGAffineTransform(rotationAngle: rotationAngle)
        // empalmamos dos transofrmaciones
        let scaleFactor = min(80/abs(imageView.center.x - self.view.bounds.width / 2), 1)
        var scaleAndRotate = rotation.scaledBy(x: scaleFactor, y: scaleFactor)
        imageView.transform = rotation
        
        if gestureRecognizer.state == .ended {
            if imageView.center.x < 100 {
                print("Reject User")
            } else if imageView.center.x >= self.view.bounds.width - 100 {
                // Logica de creacion de la relacion de amistad
                self.users[self.userIndex].isFriend = true
                
                // Creamos la relación de amistad por medio del modelo de BD correspondiente (Parse)
                let friendship = PFObject(className: "UserFriends")
                friendship["idUser"] = PFUser.current()?.objectId
                friendship["idFriend"] = self.users[self.userIndex].objectID
                
                // Importante: al crear un registro si le quiero meter permisos de escritura debo hacerlo a nivel de registro
                // creando un ACL y dándole permisos de escritura públicos
                let acl = PFACL()
                acl.getPublicReadAccess = true
                acl.getPublicWriteAccess = true
                friendship.acl = acl
                
                // Guardamos el objeto en backend: no usamos bloque de completación porque es una operación sencilla
                // y no se necesita feedback al usuario. Si no usaríamos el bloque como de costumbre
                friendship.saveInBackground()
                
                // Recargamos el listado de candidatos porque tengo un nuevo amigo y no debe salir de nuevo
                self.users = UsersFactory.instance.getUnknownPeople()
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            scaleAndRotate = rotation.scaledBy(x: 1, y: 1)
            imageView.transform = scaleAndRotate
            imageView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            reloadView()
        }
    }

}
