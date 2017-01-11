//
//  FeedViewController.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 10/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var posts: [Post] = []
    var query: PostsQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            // Si hemos sido revelados por el controlador del Reveal lo usamos a el como controlador en lugar de 
            // ser nosotros los que gestionemos
            self.menuButton.target = self.revealViewController()
            // Acción del selector
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            // Añadimos el reconocedor del gesto de swipe para que la barra de navegación aparezca progresivamente al arrastrar
            // y no solo al pulsar el botón de menú
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh posts")
        self.tableView.refreshControl?.addTarget(self, action: #selector(self.loadPosts), for: .valueChanged)
    }
    
    func refreshPosts(notification: NSNotification) {
        if let notificationData = notification.userInfo as? [String: Post] {
            self.posts.append(notificationData["post"]!)
            self.tableView.reloadData()
            // Codigo para refrescar celdas concretas de la tabla
            // let indexPath = IndexPath(item: self.posts.count, section: 0)
            // self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        self.tableView.refreshControl?.endRefreshing()
    }
    
    
    func loadPosts() {
        NotificationCenter.default.removeObserver(self, name: UsersFactory.NOTIFICATION_NAME, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPosts), name: PostsQuery.NOTIFICATION_NAME, object: nil)
        self.query = PostsDAO.instance.getPosts(notFromUser: (PFUser.current()?.objectId!)!)
        self.query!.getResults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadPosts), name: UsersFactory.NOTIFICATION_NAME, object: nil)
        // Inicializacion de las factorias nada más arrancar (lazy). Siempre hacer inicializaciones después de suscribirse a notificaciones para
        // no tener problemas con los hilos
        UsersFactory.instance.loadUsers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UsersFactory.NOTIFICATION_NAME, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feedCell = self.tableView.dequeueReusableCell(withIdentifier: "feedCell") as! FeedCell
        let post = self.posts[indexPath.row]
        if let userImage = post.postedBy.thumbnail {
            feedCell.userImage.image = userImage
        }
        feedCell.userName.text = post.postedBy.name
        feedCell.postDate.text = post.postDate
        feedCell.post.text = post.postContent
        feedCell.postImage.image = post.postImage
        return feedCell
    }
    
    //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    <#code#>
    //}
}

extension FeedViewController: UITableViewDelegate {
    
}
