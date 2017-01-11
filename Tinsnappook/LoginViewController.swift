/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // Activity Indicator para dar feedback de las operaciones al usuario
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Al cargar la página, si el usuario tiene sesión activa entonces le mando directamente a pantalla principal
        // sin necesidad de logarse de nuevo
        if PFUser.current() != nil {
            self.performSegue(withIdentifier: "showMainVc", sender: nil)
        }
        
        // Ocultamos la barra de navegacion, no me interesa en esta pantalla
        self.navigationController?.navigationBar.isHidden = true
    }
    @IBAction func signUpPressed(_ sender: UIButton) {
        if self.infoCompleted() {
            print("User \(self.emailField.text) signed up")
            self.startActivityIndicator()
            let user = PFUser()
            user.username = self.emailField.text
            user.email = self.emailField.text
            user.password = self.passwordField.text
            
            // Definimos permisos de lectura y escritura para el usuario
            let acl = PFACL()
            acl.getPublicReadAccess = true
            acl.getPublicWriteAccess = true
            user.acl = acl
            
            user.signUpInBackground(block: { (success, error) in
                self.stopActivityIndicator()
                self.checkParseError(error: error, errorTitle: "Sign Up Error")
                if error == nil {
                    UsersFactory.instance.loadCurrentUser()
                    self.performSegue(withIdentifier: "showMainVc", sender: nil)
                }
            })
        }
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        if self.infoCompleted() {
            print("User logger in")
            self.startActivityIndicator()
            PFUser.logInWithUsername(inBackground: self.emailField.text!, password: self.passwordField.text!, block: { (user, error) in
                self.stopActivityIndicator()
                self.checkParseError(error: error, errorTitle: "Log In Error")
                if error == nil {
                    UsersFactory.instance.loadCurrentUser()
                    self.performSegue(withIdentifier: "showMainVc", sender: nil)
                }
            })
        }
    }
    
    func checkParseError(error: Error?, errorTitle: String) {
        if error != nil {
            var errorMessage = "Error accessing Parse backend"
            if let parseError = error?.localizedDescription {
                errorMessage = parseError
            }
            self.showInformativeAlert(title: errorTitle, message: errorMessage)
        }
    }
    
    func startActivityIndicator() {            // Los activity indicator tienen normalmente tamaño 50x50
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = .gray
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        // Deja de escuchar toques a la pantalla desde este momento, al presentar el activity Indicator
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator() {                // Descongelamos la pantalla con el activity indicator
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @IBAction func lostPasswordPressed(_ sender: UIButton) {
        let alertWithText = UIAlertController(title: "Recover Password", message: "Enter your registered email in Tinsnappook", preferredStyle: .alert)
        alertWithText.addTextField { (textfield) in
            textfield.placeholder = "example@domain.com"
        }
        let okAction = UIAlertAction(title: "Get my Password", style: .default) { (action) in
            let restorationEmail = alertWithText.textFields![0] as UITextField
            PFUser.requestPasswordResetForEmail(inBackground: restorationEmail.text!, block: { (success, error) in
                self.checkParseError(error: error, errorTitle: "Password Restoration Error")
                if (error == nil) {
                    self.showInformativeAlert(title: "Password Restored", message: "Your password has been restored. Check your email inbox for instructions to recover your password")
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Forget It", style: .cancel, handler: nil)
        alertWithText.addAction(okAction)
        alertWithText.addAction(cancelAction)
        self.present(alertWithText, animated: true, completion: nil)
    }
    
    func infoCompleted() -> Bool {
        let infoCompleted = !(self.emailField.text == "" || self.passwordField.text == "")
        if(!infoCompleted) {
            showInformativeAlert(title: "Check Your Data", message: "Be sure you enter a valid email and password please")
        }
        return infoCompleted
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInformativeAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    //    func testParseSave() {
    //        // Instanciacion de un objeto parse (tipo PFObject) y le ponemos el nombre de clase que queramos
    //        let testObject = PFObject(className: "MyTestObject")
    //        // Las clases son diccionarios, así que se tramitan así, como diccionarios
    //        testObject["foo"] = "bar"
    //        // Guardado en background, se comprueba al terminar el método de salvado si hay error o todo OK
    //        testObject.saveInBackground { (success, error) -> Void in
    //            if success {
    //                print("El objeto se ha guardado en Parse correctamente.")
    //            } else {
    //                if error != nil {
    //                    print (error?.localizedDescription)
    //                } else {
    //                    print ("Error")
    //                }
    //            }
    //        }
    //    }

//    func testParseQuery() {
//        // Esta query obtiene todos los objetos de esa clase
//        let query = PFQuery(className: "MyTestObject")
//        // Se pide un objeto con un ID determinado. Típicamente en lugar de esto haremos una query con criterios de consulta
//        // Se ejecuta en segundo plano para no congelar la ejecuión de la aplicación e implementamos el bloque de completación
//        query.getObjectInBackground(withId: "IRMP2gpe7b", block: { (result, error) -> Void in
//            if error != nil {
//                print (error?.localizedDescription)
//            } else {
//                if let test = result {
//                    print(test)
//                    print(test["foo"])
//                }
//            }
//        })
//    }
}

extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
