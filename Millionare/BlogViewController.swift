//
//  BlogViewController.swift
//  Millionare
//
//  Created by delta on 11/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import UIKit
import FirebaseStorage
import Floaty

class BlogViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private let cache = NSCache<AnyObject,AnyObject>()
    
    @IBOutlet weak var floaty: Floaty!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BlogTableViewCell
        
        if let img = cache.object(forKey: self.blogs[indexPath.row].icon as AnyObject) as? UIImage{
            cell.blogIcon.image = img
            
        }else{
            let myurl = URL(string: self.blogs[indexPath.row].icon)
            let data = try? Data(contentsOf: myurl!)
            if data == nil {
                self.displayErrorMessage(title: "No Internet Connection", message: "Please connect to Wi-Fi or mobile data to view the blog.")
            } else {
                DispatchQueue.global(qos: .default).async{
                    
                    let myurl = URL(string: self.blogs[indexPath.row].icon)
                    let data = try? Data(contentsOf: myurl!)
                    
                    let final_img = UIImage(data:data!)
                    self.cache.setObject(final_img!, forKey: self.blogs[indexPath.row].icon as AnyObject)
                    DispatchQueue.main.async{
                        cell.blogIcon.image = final_img
                    }
                    
                }
            }
            
        }
        cell.blogTitle.text = blogs[indexPath.row].title
        cell.username.text = blogs[indexPath.row].username
        if blogs[indexPath.row].usericon.elementsEqual("none"){}
        else {
            if let img = cache.object(forKey: self.blogs[indexPath.row].usericon as AnyObject) as? UIImage{
                cell.userIcon.image = img
            }else{
                DispatchQueue.global(qos: .default).async{
                    
                    let myurl = URL(string: self.blogs[indexPath.row].usericon)
                    print(self.blogs[indexPath.row].usericon)
                    if let data = try? Data(contentsOf: myurl!){
                        let final_img = UIImage(data:data)
                        self.cache.setObject(final_img!, forKey: self.blogs[indexPath.row].usericon as AnyObject)
                        DispatchQueue.main.async{
                            cell.userIcon.image = final_img
                        }
                    }
                    
                }
            }
            
        }
        return cell
    }
    
    
    @IBOutlet var blogTable: UITableView!
    var lol:[String]=[]
    
    var blogs:[Blog]=[]
    
    var refBlog: DatabaseReference!
    
    var storageRef: StorageReference!
    
    var storage: Storage!
    
    var refUsers: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blogTable.dataSource = self
        var tempblogs:[Blog]=[]
        refBlog = Database.database().reference().child("blog")
        storage = Storage.storage()
        storageRef = storage.reference()
        refBlog.observe(.value)
        {   (DataSnapshot) in
            for child in DataSnapshot.children{
                let snap = child as! DataSnapshot
                let placeDict = snap.value as! [String: AnyObject]
                let title = placeDict["Title"] as! String
                let content = placeDict["Content"] as! String
                let icon = placeDict["Icon"] as! String
                let userid = placeDict["UserID"] as! String
                let username = placeDict["Username"] as! String
                let id = placeDict["id"] as! String
                let usericon = placeDict["UserIcon"] as! String
                let temp = Blog(id: id, title: title, icon: icon, usericon: usericon, content: content, username: username, userid: userid)
                print(temp.id)
                tempblogs.append(temp)
                print("\(tempblogs.count)")
            }
            self.blogs.removeAll()
            self.blogs = tempblogs
            tempblogs.removeAll()
            print("\(self.blogs.count)")
            self.blogTable.reloadData()
        }
        
        // Floating Action Button
        floaty.addItem(title: "Add New Blog", handler: {_ in
            self.performSegue(withIdentifier: "addNewBlog", sender: self)
        })
        self.view.addSubview(floaty)
        
        blogTable.reloadData()        // Do any additional setup after loading the view.
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "blogSegue",let destination = segue.destination as? BlogDetailViewController, let blogIndex = blogTable.indexPathForSelectedRow?.row{
            destination.blogContent = blogs[blogIndex].content
            destination.blogTitle = blogs[blogIndex].title
            destination.blogIcon = blogs[blogIndex].icon
            destination.cache=cache
        }
    }
    
    func displayErrorMessage (title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: false, completion: nil)
    }
    
    
    
    
}
