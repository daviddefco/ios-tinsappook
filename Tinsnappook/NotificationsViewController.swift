//
//  NotificationsViewController.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 10/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
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
