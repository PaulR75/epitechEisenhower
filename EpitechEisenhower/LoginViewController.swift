//
//  ViewController.swift
//  EpitechEisenhower
//
//  Created by fauquette fred on 25/09/17.
//  Copyright © 2017 Epitech. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import FirebaseStorage


// UIColor extension for hex
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

// Declaration of colors for error message
let redColor: UIColor = UIColor(rgb: 0xFF3A07).withAlphaComponent(0.8)
let greenColor: UIColor = UIColor(rgb: 0x7EFF21).withAlphaComponent(1)
let clearGreenColor: UIColor = UIColor(rgb: 0xF8E81C).withAlphaComponent(0.4)
let blueColor: UIColor = UIColor(rgb: 0x0DA0B2).withAlphaComponent(0.8)

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var EHErrorMessage: UILabel!
    @IBOutlet weak var EHpasswordField: UITextField!
    @IBOutlet weak var EHemailField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var EHSigninButton: UIButton!
    @IBOutlet weak var GoogleSignInButton: GIDSignInButton!
    var handle: AuthStateDidChangeListenerHandle?
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Firebase handler to detect authentication status changement
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Authentication status changed")
            if (user != nil){
                self.createUserDocument(user!)
                self.performSegue(withIdentifier: "showHome", sender: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        removeNavigationBarShadow()
        title = "Login"
        
        // TO DO (FCT) -- Create extension of UIButton, all same layer in the app.
        connectButton.layer.cornerRadius = 5
        EHSigninButton.layer.cornerRadius = 5
        
        // TO DO (FCT) -- Create extension of UITextField with auto-padding, cornerRadius, placeHolder colors.
        EHemailField.layer.cornerRadius = 5
        EHpasswordField.layer.cornerRadius = 5
        setPaddingLeft(paddingWidth: 15, textField: EHemailField)
        setPaddingLeft(paddingWidth: 15, textField: EHpasswordField)
    }
    
    // TRICKS. TO DO -- Find correct way of removing it through InterfaceBuilder
    func removeNavigationBarShadow(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // TO DO (FCT) -- Create extension of UITextField with auto-padding, cornerRadius, placeHolder colors.
    func setPaddingLeft(paddingWidth: CGFloat, textField: UITextField){
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: textField.frame.height))
        textField.leftView = padding
        textField.leftViewMode = UITextFieldViewMode.always
    }

    // Email signin
    @IBAction func signin(_ sender: Any) {
        if (EHemailField.text!.count > 0 && EHpasswordField.text!.count > 0){
            Auth.auth().createUser(withEmail: EHemailField.text!, password: EHpasswordField.text!) { (user, error) in
                if (error != nil){
                    print(error!.localizedDescription)
                    self.EHErrorMessage.textColor = redColor
                    self.EHErrorMessage.text = error!.localizedDescription
                    return
                }
                self.EHErrorMessage.textColor = greenColor
                self.EHErrorMessage.text = "Account has been created. You can now login."
                print(user!.email!)
                
            }
        }
        else{
            self.EHErrorMessage.textColor = redColor
            self.EHErrorMessage.text = "Credentials are empty."
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        if FBSDKAccessToken.current() != nil {
            self.FBFirebaseSignin()
            return
        }
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err!)
                return
            }
            else{
                print("here")
                if (FBSDKAccessToken.current() != nil){
                    self.FBFirebaseSignin()
                }
            }
        }
    }

    func FBFirebaseSignin(){
        let credentials = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credentials) { (user, error) in
            if (user != nil){
                print(user!.uid)
                print(FBSDKAccessToken.current().userID)
                let imagesRef = Storage.storage().reference().child("images/\(user!.uid).jpg")
                let urlString: String = "https://graph.facebook.com/\(FBSDKAccessToken.current().userID!)/picture?width=200&height=200"
                print(urlString)
                let url = URL(string: urlString)
                self.uploadFile(imagesRef, url!)
            }
        }
    }
    
    func createUserDocument(_ user: User){
        let db = Firestore.firestore()
        var data: [String:String] = [String:String]()
        data["email"] = user.email
        data["name"] = user.displayName
        data["provider"] = user.providerData.first?.providerID
        data["description"] = "Here you can write a short description about yourself."
        let docRef = db.collection("users").document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document {
                switch document.exists{
                case true:
                    print("documents already exists")
                    break
                case false:
                    db.collection("users").document(user.uid).setData(data, options: SetOptions.merge())
                    break
                }
            }
        }
    }
    
    func uploadFile(_ fileRef: StorageReference, _ url: URL){
        let data = NSData(contentsOf: url)
        fileRef.getMetadata { (metadata, error) in
            if (error != nil){
                let storageError = error! as NSError
                let errorCode: StorageErrorCode = StorageErrorCode(rawValue: storageError.code)!
                if (errorCode == .objectNotFound){
                    print("File doesn't exist")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    _ = fileRef.putData(data! as Data, metadata: metadata)
                }
            }
            else{
                print("File exists")
            }
//            if (errorCode == .objectNotFound){
//                print("File doesn't exist")
//                let metadata = StorageMetadata()
//                metadata.contentType = "image/jpeg"
//                _ = fileRef.putData(data! as Data, metadata: metadata)
//            }
//            else{
//                print("File exists")
//            }
        }
    }

    // Email login
    @IBAction func connect(_ sender: Any) {
        if (EHemailField.text!.count > 0 && EHpasswordField.text!.count > 0){
            Auth.auth().signIn(withEmail: EHemailField.text!, password: EHpasswordField.text!) { (user, error) in
                if (error != nil){
                    print(error!.localizedDescription)
                    self.EHErrorMessage.textColor = redColor
                    self.EHErrorMessage.text = error!.localizedDescription
                }
            }
        }
    }
}

