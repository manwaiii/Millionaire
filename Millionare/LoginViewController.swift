//
//  LoginViewController.swift
//  Millionare
//
//  Created by delta on 7/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FBSDKLoginKit


typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController, GIDSignInDelegate {
    var refUsers: DatabaseReference!
    
    @IBOutlet var pwTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    
    
    @IBAction func facebookButton(_ sender: Any) {
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: readPermissions, viewController: self, completion: didReceiveFacebookLoginResult)
        
    }
    @IBAction func googleButton(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func SigninButton(_ sender: Any) {
        let loginManager = FirebaseAuthManager()
        let email = emailTextField.text!
        let password = pwTextField.text!
        
        if !(email == "" || password == ""){
            
            Auth.auth().fetchSignInMethods(forEmail: email, completion: { (providers, error) in
                if providers == nil {
                       // user doesn't exist
                    self.displayErrorMessage(message: "The user does not exist. Please sign up.")
                  } else {
                       // user does exist
                   
                    loginManager.signIn(email: email, pass: password) {[weak self] (success) in
                        guard let `self` = self else { return }
                        if (success) {
                            self.performSegue(withIdentifier: "loginToHome", sender: nil)
                            
                            
                        } else {
                            self.displayErrorMessage( message: "Username or password incorrect.")
                        }
                    }
                  }
            })
            
        }
        else { displayErrorMessage(message: "Username and password cannot be empty") }
        
    }
    
    
    private let readPermissions: [Permission] = [ .publicProfile, .email, .userFriends, .custom("user_posts") ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refUsers = Database.database().reference().child("user");
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        //
        //
        ////         Automatically sign in google the user.
        //        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        //        Auto sign in
        Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
                self.emailTextField.text = nil
                self.pwTextField.text = nil
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    private func didReceiveFacebookLoginResult(loginResult: LoginResult) {
        switch loginResult {
        case .success:
            didLoginWithFacebook()
        case .failed(_): break
        default: break
        }
    }
    
    
    fileprivate func didLoginWithFacebook() {
        // Successful log in with Facebook
        if let accessToken = AccessToken.current {
            // If Firebase enabled, we log the user into Firebase
            FirebaseAuthManager().login(credential: FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)) {[weak self] (success) in
                guard let `self` = self else { return }
                var message: String = ""
                if (success) {
                    message = "User was sucessfully logged in."
                    let userID = Auth.auth().currentUser?.uid
                    let firstname = self.refUsers.child(userID!).child("first_name")
                    firstname.observeSingleEvent(of : .value, with : {(Snapshot) in
                        if let firstname = Snapshot.value as? String{
                            print(firstname)
                        }else{
                            self.addUser()
                        }})
                    
                    
                    self.performSegue(withIdentifier: "loginToHome", sender: nil)
                } else {
                    message = "There was an error."
                }
                print(message)
            }
        }
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
extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        
        print("handle user signup / login")
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FirebaseAuth.User?, error: Error?) {
        // ...
        
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //Sign in functionality will be handled here
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Login Successful.")
                let userID = Auth.auth().currentUser?.uid
                let firstname = self.refUsers.child(userID!).child("first_name")
                firstname.observeSingleEvent(of : .value, with : {(Snapshot) in
                    if let firstname = Snapshot.value as? String{
                        print(firstname)
                    }else{
                        self.addUser()
                    }})
                
                //This is where you should add the functionality of successful login
                //i.e. dismissing this view or push the home view controller etc
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
                
            }
        }
    }
    func addUser() {
        
        let userid = Auth.auth().currentUser?.uid
        let firstname = Auth.auth().currentUser?.displayName
        let email = Auth.auth().currentUser?.email
        
        let user = ["id":userid,
                    "first_name": firstname,
                    "last_name": "",
                    "email" : email,
                    
        ]
        
        //adding the artist inside the generated unique key
        self.refUsers.child(userid!).setValue(user)
    }
    
    func displayErrorMessage (title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: false, completion: nil)
    }
    
    
}

