//
//  AlertFactory.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 12/1/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class AlertFactory: NSObject {
    static let instance = AlertFactory()
    
    func createInformativeAlert(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        return alertController
    }
}
