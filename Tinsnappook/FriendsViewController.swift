//
//  FriendsViewController.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 10/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FriendsViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var users : [User] = []
    
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
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh new friends")
        self.refreshControl?.addTarget(self, action: #selector(self.loadUsers), for: .valueChanged)
        
        UserGenerator.instance.generateBots()
        
        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadUsers()
    }
    func loadUsers() {
        self.users = UsersFactory.instance.findFriends()
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = self.users[indexPath.row]
        
        cell.userName.text = user.name
        cell.userImage.image = user.thumbnail != nil ? user.thumbnail : #imageLiteral(resourceName: "no-friend")
        
        // Ponemos la imagen circular
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2.0
        cell.userImage.clipsToBounds = true
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
/*
        Funcionalidad movida al discover VC
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")
        
        if (self.users[indexPath.row].isFriend == true) {
            // Dejamos de ser amigos
            cell?.accessoryType = .none
            self.users[indexPath.row].isFriend = false
            
            let query = PFQuery(className: "UserFriends")
            query.whereKey("idUser", equalTo: (PFUser.current()?.objectId)!)
            query.whereKey("idFriend", equalTo: self.users[indexPath.row].objectID)
            
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
        } else {
            // Marcamos la celda seleccionada con un check en la celda
            cell?.accessoryType = .checkmark
            self.users[indexPath.row].isFriend = true
            
            // Creamos la relación de amistad por medio del modelo de BD correspondiente (Parse)
            let friendship = PFObject(className: "UserFriends")
            friendship["idUser"] = PFUser.current()?.objectId
            friendship["idFriend"] = self.users[indexPath.row].objectID
            
            // Importante: al crear un registro si le quiero meter permisos de escritura debo hacerlo a nivel de registro
            // creando un ACL y dándole permisos de escritura públicos
            let acl = PFACL()
            acl.getPublicReadAccess = true
            acl.getPublicWriteAccess = true
            friendship.acl = acl
            
            // Guardamos el objeto en backend: no usamos bloque de completación porque es una operación sencilla
            // y no se necesita feedback al usuario. Si no usaríamos el bloque como de costumbre
            friendship.saveInBackground()
        }
 */
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let destinationVC = segue.destination as! PublicProfileViewController
            destinationVC.user = self.users[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
}
