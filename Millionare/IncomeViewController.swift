//
//  IncomeViewController.swift
//  Millionare
//
//  Created by Kanon on 10/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import UIKit
import FirebaseStorage

class IncomeViewController: UIViewController, UITextFieldDelegate {
    
    var refUser: DatabaseReference!
    var storageRef: StorageReference!
    var storage: Storage!
    
    @IBOutlet var buttonSelected: [UIButton]!
    
    // Grey one button if user pressed
    @IBAction func greySelectedButton(_ sender: UIButton) {
        for button in buttonSelected{
            button.backgroundColor = UIColor.clear
        }
        sender.backgroundColor = UIColor.gray
    }
    
    @IBOutlet var titleText: UITextField!
    @IBOutlet var valueText: UITextField!
    @IBOutlet var date: UIDatePicker!
    
    @IBAction func salary(_ sender: AnyObject) {categoryInput(input: "salary")}
    @IBAction func bonus(_ sender: AnyObject) {categoryInput(input: "bonus")}
    @IBAction func investment(_ sender: AnyObject) {categoryInput(input: "investment")}
    @IBAction func allowance(_ sender: AnyObject) {categoryInput(input: "allowance")}
    @IBAction func gift(_ sender: AnyObject) {categoryInput(input: "gift")}
    @IBAction func others(_ sender: AnyObject) {categoryInput(input: "others")}
    
    var category: String = ""
    var year: String = ""
    var month: String = ""
    var day: String = ""
    var titleOp: String = ""
    var id = 0
    var value:Double = 0.0
    var categoryFlag = false
    
    @IBAction func save(_ sender:AnyObject){
        if let tmp = Double(valueText.text!) {              //value input is a value
            if categoryFlag{
                if titleText.text == ""{                        //have no title
                    titleOp = "nil"
                } else {
                    titleOp = titleText.text!                   //have title
                }
                value = tmp
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day,.month,.year], from: date.date)
                if let dayGet = components.day, let monthGet = components.month, let yearGet = components.year {
                    day = String(dayGet)
                    month = String(monthGet)
                    year = String(yearGet)
                }
                addIncomeRecord()
                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
            }                                                //update database
            else {
                showAlert()
            }
        } else {
            showAlert()                                      //value input is not value
        }
        valueText.resignFirstResponder()
        titleText.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: AnyObject){
        titleText.text = ""
        valueText.text = ""
        year = ""
        month = ""
        day = ""
        value = 0.0
    }
    
    func categoryInput(input: String){
        categoryFlag = true
        category = input
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Data Validation Error", message: "There was an error of not proper input or no category chose.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {(action: UIAlertAction!) in print("Data Validation Checking Completed")}))
        present(alert, animated: true, completion: nil)
    }
    
    func addIncomeRecord(){
        storage = Storage.storage()
        storageRef = storage.reference()
        refUser = Database.database().reference().child("user");
        // Do any additional setup after loading the view.
        let user = Auth.auth().currentUser
        let userID = user?.uid
        
        //generating a new key inside artists node
        //and also getting the generated key
        refUser = Database.database().reference().child("income").child(String(userID!))
        
        let key = refUser.childByAutoId().key
        //creating artist with the given values
        
        let income = ["id": key,
                      "userID": String(userID!),
                      "title": titleOp,
                      "value": String(value),
                      "day": day,
                      "month": month,
                      "year": year,
                      "category": category
                        ]
    
        //adding the income record inside the generated unique key
        refUser.child(String(key!)).setValue(income)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        valueText.delegate = self
        titleText.delegate = self
    }


}
