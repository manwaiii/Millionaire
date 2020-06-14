//
//  Blog.swift
//  Millionare
//
//  Created by Michael Chan on 15/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import Foundation
class Blog
{
    var id:String
    var title:String
    var icon:String
    var usericon:String
    var content:String
    var username:String
    var userid:String
    init(id:String,title:String,icon:String,usericon:String,content:String,username:String,userid:String){
        self.id = id
        self.title = title
        self.icon = icon
        self.usericon = usericon
        self.content = content
        self.username = username
        self.userid = userid
    
    }
    
    
    
}
