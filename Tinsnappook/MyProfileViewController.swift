//
//  MyProfileViewController.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 10/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdateLabel: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    var user : User?
    
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
        
        // Asignamos el delegado y ponemos una extension para ocultar el teclado al acabar de editar
        
        self.nameTextfield.delegate = self
        
        // El nombre lo cargo solo la primera vez para que no me elimine ediciones si cambio de vista por el
        // image picker o el date picker
        self.user = UsersFactory.instance.currentUser!
        self.nameTextfield.text = user?.name
        
        self.userImage.layer.cornerRadius = self.userImage.frame.height / 2
        self.userImage.layer.masksToBounds = false
        self.userImage.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.user = UsersFactory.instance.currentUser!
        
        if let image = user?.thumbnail {
            self.userImage.image = image
        } else {
            self.userImage.image = #imageLiteral(resourceName: "no-friend")
        }
        
        if let birthdate = user?.birthDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            self.birthdateLabel.setTitle(dateFormatter.string(from: birthdate), for: .normal)
        } else {
            self.birthdateLabel.setTitle("Unknown", for: .normal)
        }
        
        if let gender = user?.gender {
            self.genderSwitch.isOn = gender
            if (user?.gender)! {
                self.genderLabel.text = "Female"
            } else {
                self.genderLabel.text = "Male"
            }
        } else {
            self.genderLabel.text = "Unknown"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }

    @IBAction func pickPhotoClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: "select an Image", message: "Where do you want to get your image from?", preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.loadPhotoFromSource(source: UIImagePickerControllerSourceType.photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.loadPhotoFromSource(source: UIImagePickerControllerSourceType.camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func loadPhotoFromSource(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = source
        
        // Nos asignamos como delegado para asegurarnos de que gestionamos la seleccion de la foto nosotros mismos
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func birthDateClicked(_ sender: Any) {
        
    }
    
    @IBAction func updateProfileClicked(_ sender: UIButton) {
        let pfUser = PFUser.current()!
        pfUser["nickname"] = self.nameTextfield.text
        
        if let gender = self.user?.gender {
            pfUser["gender"] = gender
        }
        if let birthdate = self.user?.birthDate {
            pfUser["birthdate"] = birthdate
        }
        
        let imageData = UIImageJPEGRepresentation(self.userImage.image!, 0.8)
        let imageFile = PFFile(name: pfUser.username! + ".jpg", data: imageData!)
        pfUser["imageFile"] = imageFile
        pfUser.saveInBackground { (success, error) in
            if success {
                let alert = UIAlertController(title: "Updated profile", message: "Your profile has been updated succesfully", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
                //UsersFactory.instance.loadCurrentUser()
            } else {
                let alert = UIAlertController(title: "Error while uploading profile", message: error?.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func genderSwitched(_ sender: UISwitch) {
        self.user?.gender = self.genderSwitch.isOn
        if self.genderSwitch.isOn {
            self.genderLabel.text = "Female"
        } else {
            self.genderLabel.text = "Male"
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.user?.thumbnail = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension MyProfileViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
