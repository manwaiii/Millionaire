//
//  DatabaseUtil.swift
//  Millionare
//
//
//  Copyright © 2019 EE4304. All rights reserved.
//


import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DatabaseUtil {
    static let data = DatabaseUtil()
    var refUsers :  DatabaseReference!
    var storageRef: StorageReference!
    var storage: Storage!
    
   // var allusers: [String]
    private init() {
       refUsers = Database.database().reference().child("user")
    }
    
    
    
    //to return alluser in db
     func getAllUser(completion:@escaping (Array<String>, Array<String>, Array<String>, Array<String>, Array<String>, Array<String>, Array<String>) -> Void)  -> Void{
        
        var alluser: [String] = []
        var allemail: [String] = []
        var ranking: [String] = []
        var allincome: [String] = []
        var allspending: [String] = []
        var allrating: [String] = []
        var allicon: [String] = []
        var num = 0
  
        storage = Storage.storage()
        storageRef = storage.reference()
        
        refUsers.queryOrdered(byChild: "rating").observe(.value, with: { (snapshot) in
                       for child in snapshot.children {
                           let snap = child as! DataSnapshot
                           let placeDict = snap.value as! [String: AnyObject]
                           let name1 = placeDict["first_name"] as! String
                        let name2 = placeDict["last_name"] as! String
                        let name = name1 + " " + name2
                            let email = placeDict["email"] as! String
                        let income = placeDict["income"] as! Double
                        let spending = placeDict["spending"] as! Double
                        let rating = placeDict["rating"] as! Double
                
                        if let icon = placeDict["userPhoto"] as? String {
                            allicon.append(icon)
                        }
                        else {
                            allicon.append("none")
                        }
                        print("1")
                        print(allicon)
                        print("2")
                        alluser.append(name)
                        allemail.append(email)
                        allincome.append(String(income))
                        allspending.append(String(spending))
                        allrating.append(String(rating))
                        num = num + 1
                        ranking.append(String(num))
                       }
            completion(alluser.reversed(),allemail.reversed(),ranking, allincome.reversed(), allspending.reversed(), allrating.reversed(), allicon.reversed())
       // print(ranking)
                   })
     //  print(ranking)
    }
    
    func getUserIncome(completion:@escaping (Double) -> Void)  -> Void{
        let user = Auth.auth().currentUser
        let userID = user?.uid
        let ref = Database.database().reference().child("income").child(String(userID!))

        var num: Double = 0.0
         var temp: [String] = []
       // alluser = ["test","456","ac","999","test123","yyy"]
     
       ref.observe(.value, with: { (snapshot) in
                       for child in snapshot.children {
                           let snap = child as! DataSnapshot
                           let placeDict = snap.value as! [String: AnyObject]
                           let value = placeDict["value"] as! String
                        temp.append(value)
                       }
        for item in temp{
            num += Double(item)!
        }
        completion(num)
       // print(num)
                   })
     // print(num)
    }
    
    func getUserSpending(completion:@escaping (Double) -> Void)  -> Void{
        let user = Auth.auth().currentUser
        let userID = user?.uid
        let ref = Database.database().reference().child("spending").child(String(userID!))

        var num: Double = 0.0
         var temp: [String] = []
       // alluser = ["test","456","ac","999","test123","yyy"]
     
       ref.observe(.value, with: { (snapshot) in
                       for child in snapshot.children {
                           let snap = child as! DataSnapshot
                           let placeDict = snap.value as! [String: AnyObject]
                           let value = placeDict["value"] as! String
                        temp.append(value)
                       }
        for item in temp{
            num += Double(item)!
        }
        completion(num)
       // print(num)
                   })
     // print(num)
    }
    
}
