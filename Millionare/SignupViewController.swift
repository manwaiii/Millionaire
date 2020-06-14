//
//  SignupViewController.swift
//  Millionare
//
//  Created by delta on 7/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit
import Firebase

import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    var refUsers: DatabaseReference!
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var pwTextField: UITextField!
    @IBOutlet var repwTextField: UITextField!
    
    
    
    
    
    @IBAction func CreateAccountButton(_ sender: Any) {
        let signUpManager = FirebaseAuthManager()
        if let first = firstNameTextField.text, let last = lastNameTextField.text, let email = emailTextField.text, let password = pwTextField.text, let re_password = repwTextField.text {
            if (first=="" || last=="" || email=="" || password == "" || re_password == "") {
                let message: String = "All fields must be filled."
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
                
            else if(password != re_password) {
                let message: String = "Password does not match."
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                signUpManager.createUser(email: email, password: password) {[weak self] (success) in
                    guard self != nil else { return }
                    var message: String = ""
                    if (success) {
                        self!.addUser()
                        self!.performSegue(withIdentifier: "loginToHome", sender: nil)
                    } else {
                        message = "This email has already been registered."
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self?.present(alertController, animated: true, completion: nil)
                    }
                    
                    print(message)
                }
            }
            
        }
        //helppp
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        FirebaseApp.configure()
        refUsers = Database.database().reference().child("user");
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        pwTextField.delegate = self
        repwTextField.delegate = self
    }
    //
    func addUser(){
        //generating a new key inside artists node
        //and also getting the generated key
        
        let userid = Auth.auth().currentUser?.uid
        
        
        //creating artist with the given values
        let user = ["id":userid as! String,
                    "first_name": firstNameTextField.text! as String,
                    "last_name": lastNameTextField.text! as String,
                    "email" : emailTextField.text! as String,
                    "income" : 0.0 as Double,
                    "spending" : 0.0 as Double,
                    "rating" : 0.0 as Double
            
            ] as [String : Any]
        
        //adding the artist inside the generated unique key
        refUsers.child(userid!).setValue(user)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    /*
     MARK: - Navigation
     
     In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     Get the new view controller using segue.destination.
     Pass the selected object to the new view controller.
     }
     */
    
}

