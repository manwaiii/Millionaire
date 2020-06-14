//
//  AddBlogViewController.swift
//  Millionare
//
//  Created by Michael Chan on 13/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import UIKit
import FirebaseStorage

class AddBlogViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    var refUsers: DatabaseReference!
    var dbRef: DatabaseReference!
    var storageRef: StorageReference!
    var storage: Storage!
    
    @IBAction func Exit(_ sender: Any?) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBOutlet var blogtitleInput: UITextField!
    @IBOutlet var blogcontentInput: UITextView!
    @IBOutlet var blogIcon: UIImageView!
    
    @IBAction func uploadphoto(_ sender: Any) {
        //   let image = UIImagePickerController()
        //  image.delegate = self
        // image.sourceType = UIImagePickerController.SourceType.photoLibrary
        // image.allowsEditing = true
        // self.present(image,animated:true){}
        
        let imagePickerController = UIImagePickerController()
        
        
        imagePickerController.delegate = self
        
        
        let imagePickerAlertController = UIAlertController(title: "Image Upload", message: "Please select the image to upload", preferredStyle: .actionSheet)
        
        
        let imageFromLibAction = UIAlertAction(title: "Gallery", style: .default) { (Void) in
            
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "Camera", style: .default) { (Void) in
            
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (Void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        
        present(imagePickerAlertController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func submit(_ sender: Any) {
        if let blogTitle = blogtitleInput.text, let blogContent = blogcontentInput.text, let Icon = blogIcon.image{
            
            var download:String="none"
            var username:String=""
            storage = Storage.storage()
            storageRef = storage.reference()
            // dbRef = Database.database().reference().child("user");
            // Do any additional setup after loading the view.
            refUsers = Database.database().reference().child("user");
            let user = Auth.auth().currentUser
            let userID = user?.uid
            
            let firstname = refUsers.child(userID!).child("first_name")
            let lastname = refUsers.child(userID!).child("last_name")
            
            
            firstname.observe(.value, with : {(Snapshot) in
                if let first = Snapshot.value as? String{ username = first + " "}})
            lastname.observe(.value, with : {(Snapshot) in
                if let last = Snapshot.value as? String{ username.append(last)}
                else {
                    let name = Auth.auth().currentUser?.displayName
                    username = name!
                }
            })
            
            refUsers.child(userID!).observe(.value, with: { (snapshot) in
                // check if user has photo
                if snapshot.hasChild("userPhoto"){
                    // set image locatin
                    let filePath = "\(userID!)/\("userPhoto")"
                    // Assuming a < 10MB file, though you can change that
                    self.storageRef.child(filePath).downloadURL { (url, error) in
                        guard let dlurl = url else {return}
                        download = dlurl.absoluteString
                    }
                }
            })
            
            
            
            //generating a new key inside artists node
            //and also getting the generated key
            dbRef = Database.database().reference().child("blog")
            
            let key = dbRef.childByAutoId().key
            //creating artist with the given values
            let iconpath = "\(String(key!))/\("blogIcon")"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            // Data in memory
            var data = Data()
            data = Icon.jpegData(compressionQuality: 0.8)!            // Create a reference to the file you want to upload
            let imageref = storageRef.child(iconpath)
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = imageref.putData(data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                imageref.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                    let blog = ["id": key,
                                "UserID": String(userID!),
                                "Title": blogTitle,
                                "Content": blogContent,
                                "Icon":url?.absoluteString,
                                "Username":username,
                                "UserIcon":download,
                    ]
                    self.dbRef.child(String(key!)).setValue(blog)
                    
                }
                
            }
            
            showComplete()
            blogtitleInput.text=""
            blogcontentInput.text=""
            blogIcon.image=nil
            
        }else{
            
            showAlert()
            
        }
        
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Data Validation Error", message: "Please make sure you have input all information.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {(action: UIAlertAction!) in print("Data Validation Checking Completed")}))
        present(alert, animated: true, completion: nil)
    }
    
    func showComplete(){
        let alert = UIAlertController(title: "Blog Uploaded", message: "Thank you for writing a blog.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {(action: UIAlertAction!) in print("Complete")}))
        present(alert, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            blogIcon.image = image
            
        }else{
            
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
