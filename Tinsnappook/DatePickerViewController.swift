//
//  DatePickerViewController.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 7/12/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveDateClicked(_ sender: UIButton) {
        let birthDate = self.datePicker.date
        UsersFactory.instance.currentUser?.birthDate = birthDate
        
        // No puedo hacer un dismiss porque cierra toda la jerarquía de navegacion
        // Lo que quiero es ir hacia atras, eliminar el primero de la cola de vistas
        // self.dismiss(animated: true, completion: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
}
