//
//  ResetPasswordViewController.swift
//  Millionare
//
//  Created by delta on 15/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit

import FirebaseAuth

class ResetPasswordViewController: UIViewController {
   
    @IBOutlet var emailTextField: UITextField!
    
    @IBAction func sendButton(_ sender: Any) {
        if let email = emailTextField!.text {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
              // ...
                if error != nil {
                  
                      self.displayMessage(message: "The user does not exist. Please sign up.szs")
                } else {
                    self.displayMessage(title:"Success", message: "An reset password e-mail has been sent to you email account.")
                  
                }
              
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    func displayMessage (title: String = "Error", message: String) {
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

}
