//
//  RankingCalc.swift
//  Millionare
//
//  
//  Copyright © 2019 EE4304. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class RankingCalc {
    
    static let data = RankingCalc()
    var refUsers :  DatabaseReference!
    //var name: [String]
    //var email: [String]
    //var Rating: Double
    //var Ranking: String
    // var allusers: [String]
     private init() {
        let user = Auth.auth().currentUser
        let userID = user?.uid
        refUsers = Database.database().reference().child("user")
     }
     
     
     //remove later
      func getData() -> [String]{
         return ["test"]
     }
    
      func getName() -> String {
         print("get name method")
         return "eeeeeeee"
     }
    
    
    // This is used to calc the rating of user
    func saveRating(_ income: Double, _ spending: Double) -> Double {
       //If income/ spening < 1,  rating = income/spending
       //If income/spending > 1, rating = Sqrt(sqrt(income))/sqrt(sqrt(spending))
        var rating: Double = 0.0
        var temp:Double = spending
        if (temp == 0){
            temp = temp + 1
        }
        else {
        if (income / temp) <= 1{
            rating = income / temp
        }
        else
        {
            rating = sqrt(sqrt(income)) / sqrt(sqrt(temp))
        }
    }
       // print(rating)
        rating = (round(100*rating)/100)
        return  rating
    }
    

}
