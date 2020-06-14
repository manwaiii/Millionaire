//
//  SpendingModel.swift
//  Millionare
//
//  Created by mat on 13/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import Foundation

class SpendingModel {
    
    var userID: String?
    var title: String?
    var value: String?
    var day: String?
    var month: String?
    var year: String?
    var category: String?
    var id: String?
    
    init(userID: String?, title: String?, value: String?, day: String?, month: String?, year: String?, category: String?, id: String?){
        self.userID = userID
        self.title = title
        self.value = value
        self.day = day
        self.month = month
        self.year = year
        self.category = category
    }
}
