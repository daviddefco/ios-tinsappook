//
//  PostViewController.swift
//  Tinsnappook
//
//  Created by Familia de Francisco Rodriguez on 15/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

   
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappingAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postPressed(_ sender: UIButton) {
        self.startActivityIndicator()
        
        let post = PFObject(className: "Post")
        post["idUser"] = PFUser.current()?.objectId
        post["message"] = self.postTextView.text
        
        let imageData = UIImageJPEGRepresentation(postImage.image!, 0.80)
        // Le ponemos nombre en lugar de usar constructor con data solo porque si no lo trata como datos binarios
        let parseImageFile = PFFile(name: "image.jpg", data: imageData!)
        post["imageFile"] = parseImageFile
        
        post.saveInBackground { (success, error) in
            self.stopActivityIndicator()
            if error != nil {
                let alert = AlertFactory.instance.createInformativeAlert(title: "Could not Store Image", message: (error?.localizedDescription)!)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = AlertFactory.instance.createInformativeAlert(title: "Image Stored", message: "Your post has been succesfully published")
                self.present(alert, animated: true, completion: nil)
                self.postTextView.text = ""
                self.postImage.image = #imageLiteral(resourceName: "send-photo")
            }
        }
    }

    func startActivityIndicator() {            // Los activity indicator tienen normalmente tamaño 50x50
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        // Deja de escuchar toques a la pantalla desde este momento, al presentar el activity Indicator
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator() {                // Descongelamos la pantalla con el activity indicator
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @IBAction func uploadImagePressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "select an Image", message: "Where do you want to get your app from?", preferredStyle: .actionSheet)
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.postImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.postImage.contentMode = .scaleToFill
        self.postImage.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }


}

// MARK: - Hide keyboard when tapping out of the keyboard
extension PostViewController {
    func hideKeyboardWhenTappingAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

