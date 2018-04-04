//
//  ProfileViewController.swift
//  EpitechEisenhower
//
//  Created by paul on 30/03/2018.
//  Copyright © 2018 Epitech. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var EHEmailTextField: UITextField!
    @IBOutlet weak var EHNameTextField: UITextField!
    @IBOutlet weak var EHRenewPasswordButton: UIButton!
    @IBOutlet weak var EHLogoutButton: UIButton!
    @IBOutlet weak var EHProfilePicture: UIImageView!
    @IBOutlet weak var EHSaveChange: UIButton!
    @IBOutlet weak var EHDescriptionTextView: UITextView!
    static var dontShow: Bool = false
    let imagePicker = UIImagePickerController()
    
    
    // TO DO -- Move it into a helper (ex: Create a NSCache Helper)
    static var imageCache = NSCache<NSString, UIImage>()
    var currentEmail: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let docRef = db.collection("users").document(user!.uid);
        docRef.getDocument { (document, error) in
            if let document = document {
                let data = document.data()!
                let provider = data["provider"] as? String
                if (provider == "facebook.com" || provider == "google.com"){
                    self.EHEmailTextField.isUserInteractionEnabled = false
                    self.EHRenewPasswordButton.isUserInteractionEnabled = false
                    self.EHRenewPasswordButton.alpha = 0.3
                    self.EHEmailTextField.alpha = 0.3
                }
                print("Document data: \(String(describing: document.data()))")
                self.EHNameTextField.text = data["name"] as? String
                self.EHDescriptionTextView.text = data["description"] as? String
                self.EHEmailTextField.text = data["email"] as? String
                self.currentEmail = self.EHEmailTextField.text!
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (ProfileViewController.dontShow == false){
            setInfoMessage()
        }
    }

    override func viewDidLoad(){
        super.viewDidLoad()
        print("here")
        imagePicker.delegate = self
         // TO DO (FCT) -- Create extension of UIButton, all same layer in the app.
        EHLogoutButton.layer.cornerRadius = 5
        EHSaveChange.layer.cornerRadius = 5

        EHProfilePicture.layer.masksToBounds = false
        EHProfilePicture.layer.cornerRadius = EHProfilePicture.frame.size.width / 2
        EHProfilePicture.clipsToBounds = true
        // TO DO (FCT) -- Create extension of UITextField with auto-padding, cornerRadius, placeHolder colors.
        EHEmailTextField.layer.cornerRadius = 5
        EHNameTextField.layer.cornerRadius = 5

        EHDescriptionTextView.layer.cornerRadius = 5
        downloadImage()
    }
    
    // TO DO (FCT) -- Create extension of UITextField with auto-padding, cornerRadius, placeHolder colors.
    func setPaddingLeft(paddingWidth: CGFloat, textField: UITextField){
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: textField.frame.height))
        textField.leftView = padding
        textField.leftViewMode = UITextFieldViewMode.always
    }
    
    func setInfoMessage(){
        let alert = UIAlertController(title: "Notice", message: "Facebook and google+ user cannot modify their password and email, according to credentials sent by the respective provider.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Got it. Don't show this message anymore", style: UIAlertActionStyle.default, handler:dontShowAnymore))
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setAlertMessage(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func dontShowAnymore(alert: UIAlertAction!) {
        ProfileViewController.dontShow = true
    }
    
    func changeCurrentPasswordAlert(_ title: String, _ message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Current password"
            textField.isSecureTextEntry = true
        })
        let confirmAction = UIAlertAction(title: "Next", style: .default) { _ in
            Auth.auth().signIn(withEmail: Auth.auth().currentUser!.email!, password: alertController.textFields!.first!.text!) { (user, error) in
                if (error != nil){
                    self.changeCurrentPasswordAlert("Error - Current password", error!.localizedDescription)
                }
                else{
                    self.newPasswordAlert("Change your password", "Enter the new password you want to have")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func newPasswordAlert(_ title: String, _ message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "New password"
            textField.isSecureTextEntry = true
        })
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            Auth.auth().currentUser?.updatePassword(to: alertController.textFields!.first!.text!, completion: { (error) in
                if (error != nil){
                   self.newPasswordAlert("Error - Change your password", error!.localizedDescription)
                }
                else{
                    self.setAlertMessage("Success", "Your password has been updated")
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func changeCurrentPasswordAlertForEmail(_ title: String, _ message: String, _ data: [String:String]){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Current password"
            textField.isSecureTextEntry = true
        })
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            Auth.auth().signIn(withEmail: Auth.auth().currentUser!.email!, password: alertController.textFields!.first!.text!) { (user, error) in
                if (error != nil){
                    self.changeCurrentPasswordAlertForEmail("Error - Current password", error!.localizedDescription, data)
                }
                else{
                    self.updateUserEmail(data)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func downloadImage(){
        if let cachedImage = ProfileViewController.imageCache.object(forKey: Auth.auth().currentUser!.uid as NSString){
            self.EHProfilePicture.image = nil // Avoid memory leaks
            self.EHProfilePicture.image = cachedImage
            return
        }
        let imageRef = Storage.storage().reference().child("images/\(Auth.auth().currentUser!.uid).jpg")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
            } else {
                let myImage = UIImage(data: data!)
                self.EHProfilePicture.image = myImage
                ProfileViewController.imageCache.setObject(myImage!, forKey: Auth.auth().currentUser!.uid as NSString)
            }
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        changeCurrentPasswordAlert("Change your password", "Enter your current password.")
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        var data: [String:String] = [String:String]()
        data["name"] = EHNameTextField.text!
        data["description"] = EHDescriptionTextView.text!
        if (currentEmail != EHEmailTextField.text!){
            changeCurrentPasswordAlertForEmail("Current password", "Enter your current password to proceed", data)
        }
        else{
          sendChangesToDB(data)
        }
    }
    
    func updateUserEmail(_ data: [String:String]){
        let user = Auth.auth().currentUser
        user?.updateEmail(to: EHEmailTextField.text!, completion: { (error) in
            if (error != nil){
                self.setAlertMessage("Error", error!.localizedDescription)
                self.EHEmailTextField.text! = self.currentEmail
                return
            }
            var newData = data
            newData["email"] = self.EHEmailTextField.text!
            self.sendChangesToDB(newData)
        })
    }

    func sendChangesToDB(_ data: [String:String]){
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid);
        docRef.getDocument { (document, error) in
            if document != nil {
                db.collection("users").document(Auth.auth().currentUser!.uid).setData(data, options: SetOptions.merge())
                self.setAlertMessage("Changes saved", "Your data has been updated.")
                self.currentEmail = self.EHEmailTextField.text!
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        print("logout button pressed")
        do{
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signoutError as NSError {
            print ("Error signing out: %@", signoutError)
        }
    }
    
    @IBAction func changePictureButton(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            EHProfilePicture.image = pickedImage
            let fileRef = Storage.storage().reference().child("images/\(Auth.auth().currentUser!.uid).jpg")
            ProfileViewController.imageCache.setObject(pickedImage, forKey: Auth.auth().currentUser!.uid as NSString)
            uploadFile(fileRef, UIImageJPEGRepresentation(pickedImage, 0.005)!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func uploadFile(_ fileRef: StorageReference, _ data: Data){
        fileRef.getMetadata { (metadata, error) in
            if (error != nil){
                let storageError = error! as NSError
                let errorCode: StorageErrorCode = StorageErrorCode(rawValue: storageError.code)!
                if (errorCode == .objectNotFound){
                    print("File doesn't exist")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    _ = fileRef.putData(data, metadata: metadata)
                }
            }
            else{
                fileRef.delete { error in
                    if error == nil {
                        DispatchQueue.global(qos: .background).async {
                            let metadata = StorageMetadata()
                            metadata.contentType = "image/jpeg"
                            _ = fileRef.putData(data, metadata: metadata)
                        }
                    }
                }
            }
        }
    }
}
