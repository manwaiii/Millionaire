//
//  SettingsViewController.swift
//  Millionare
//
//  Created by delta on 7/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SettingsViewController: UIViewController {
    var refUsers: DatabaseReference!
    var storageRef: StorageReference!
    var storage: Storage!
    
    @IBOutlet var iconButton: UIButton!
    @IBOutlet var emailLabel: UILabel!
    @IBAction func changeNameButton(_ sender: Any) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Change name", message: "Enter a new name", preferredStyle: .alert)
        
        
        //adding textfields to our dialog box
        alertController.addTextField()
        alertController.textFields?[0].placeholder = "First Name"
        
        alertController.addTextField()
        alertController.textFields?[1].placeholder = "Last Name"
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let userid = Auth.auth().currentUser?.uid
            //getting the input values from user
            if let firstname = alertController.textFields?[0].text,
                let lastname = alertController.textFields?[1].text {
                self.refUsers.child(userid!).child("first_name").setValue(firstname)
                self.refUsers.child(userid!).child("last_name").setValue(lastname)
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        
        //finally presenting the dialog box
        self.present(alertController, animated: false, completion: nil)
    }
    
    
    @IBAction func changePwButton(_ sender: Any) {
        //check if log in by email provider
        let user = Auth.auth().currentUser
        let providerID = user?.providerData[0].providerID
        var message : String = ""
        print("myproviderid:\(providerID)")
        
        
        
        switch (providerID){
        case("facebook.com"):
            message = "Password cannot be changed because you sign in with Facebook account!"
            displayErrorMessage(message: message)
        case("google.com"):
            message = "Password cannot be change because you signed in with Google account!"
            displayErrorMessage(message: message)
        default:
            message = "Please enter your current password"
            let alertController = UIAlertController(title: "Authorization", message: message, preferredStyle: .alert)
            alertController.addTextField()
            alertController.textFields?[0].placeholder = "Password"
            alertController.textFields?[0].isSecureTextEntry = true
            
            let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
                let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: (alertController.textFields?[0].text)!)
                user?.reauthenticate(with: credential, completion: {
                    (authResult, error) in
                    if error != nil {
                        self.displayErrorMessage(message:"Password incorrect.")
                    } else {
                        //set a new password
                        let alertController = UIAlertController(title: "Change Password", message: "Please enter your new password", preferredStyle: .alert)
                        alertController.addTextField()
                        alertController.textFields?[0].placeholder = "New Password"
                        alertController.textFields?[0].isSecureTextEntry = true
                        alertController.addTextField()
                        alertController.textFields?[1].placeholder = "Re-password"
                        alertController.textFields?[1].isSecureTextEntry = true
                        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
                            if let pw = alertController.textFields?[0].text, let rePw = alertController.textFields?[1].text {
                                if (pw == rePw ) {
                                    user?.updatePassword(to:  (alertController.textFields?[0].text)!) { (errror) in
                                        if error != nil{
                                            self.displayErrorMessage(message: "Error in update password. Please try again.")
                                        } else {
                                            self.displayErrorMessage(title:"Success", message: "Your password has been updated.")
                                        }
                                    }
                                }
                                    
                                else {
                                    self.displayErrorMessage(message: "Re-password does not match.")
                                }
                            } else {
                                self.displayErrorMessage(message: "Password cannot be empty")
                            }
                        }
                        
                        //the cancel action doing nothing
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
                        
                        alertController.addAction(confirmAction)
                        alertController.addAction(cancelAction)
                        
                        //finally presenting the dialog box
                        self.present(alertController, animated: false, completion: nil)
                    }
                })
                
                
            }
            
            alertController.addAction(confirmAction)
            //the cancel action doing nothing
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addAction(cancelAction)
            
            //finally presenting the dialog box
            self.present(alertController, animated: false, completion: nil)
            
        }
    }
    
    
    @IBAction func changeIconButton(_ sender: Any) {
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        AttachmentHandler.shared.imagePickedBlock = { (raw_image) in
         
            var image = self.cropImageToSquare(image: raw_image)
            image = self.fixOrientation(image!)
            
            //set icon
            self.iconButton.setBackgroundImage(image, for: .normal)
            
            //update icon in local
            let iconData:NSData = image!.pngData()! as NSData
            UserDefaults.standard.set(iconData, forKey: "icon")
            
            
            //upload image to storage
            var data = Data()
            data = image!.jpegData(compressionQuality: 0.6)!
            // set upload path
            let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            self.storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else{
                    
                    //store downloadURL
                    let downloadURL = metaData!.path!
                    //store downloadURL at database
                    self.refUsers.child(Auth.auth().currentUser!.uid).updateChildValues(["userPhoto": downloadURL as String])
                    
                    //                            self.view.setNeedsDisplay()
                    //
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refUsers = Database.database().reference().child("user");
        // Do any additional setup after loading the view.
        storage = Storage.storage()
        storageRef = storage.reference(withPath: "gs://millionaire-94030.appspot.com")
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        refUsers = Database.database().reference().child("user");
        // Do any additional setup after loading the view.
        storage = Storage.storage()
        storageRef = storage.reference()
        let user = Auth.auth().currentUser
        let userID = user?.uid
        
        
        let email = refUsers.child(userID!).child("email")
        
        
        
        email.observe(.value, with : {(Snapshot) in
            if let emailString = Snapshot.value as? String{ self.emailLabel.text? = emailString}
        })
        
        
        //load icon from local
        if let iconData = UserDefaults.standard.object(forKey: "icon")  {
            let icon = UIImage(data: iconData as! Data)
            iconButton.setBackgroundImage(icon, for: .normal)
            
        }
        
        
        //        refUsers.child(userID!).observe(.value, with: { (snapshot) in
        //            // check if user has photo
        //            if snapshot.hasChild("userPhoto"){
        //                // set image locatin
        //                let filePath = "\(userID!)/\("userPhoto")"
        //                // Assuming a < 10MB file, though you can change that
        //                self.storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
        //
        //                    let userPhoto = UIImage(data: data!)
        //                    self.iconButton.setBackgroundImage(userPhoto, for: .normal)
        //                })
        //            }
        //        })
        
        
        
        super.viewWillAppear(animated)
        
        
    }
    
    func displayErrorMessage (title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: false, completion: nil)
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //crop image
    func cropImageToSquare(image: UIImage) -> UIImage? {
        var imageHeight = image.size.height
        var imageWidth = image.size.width

        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }

        let size = CGSize(width: imageWidth, height: imageHeight)

        let refWidth : CGFloat = CGFloat(image.cgImage!.width)
        let refHeight : CGFloat = CGFloat(image.cgImage!.height)

        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2

        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let imageRef = image.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        }

        return nil
    }
    func fixOrientation(_ img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
