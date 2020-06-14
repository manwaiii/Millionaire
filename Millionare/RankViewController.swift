//
//  SecondViewController.swift
//  Millionare
//
//  Created by delta on 5/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage


class RankViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private let cache = NSCache<AnyObject,AnyObject>()
    
    var refUsers: DatabaseReference!
    var storageRef: StorageReference!
    var storage: Storage!
    
    
    var items:[String] = []
    var email:[String] = []
    var ranking:[String] = []
    var incomes: [String] = []
    var spendings: [String] = []
    var rating: [String] = []
    var icon: [String] = []
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    
    
    var filterData: [String]!
    var filteremail: [String] = []
    var filterranking: [String] = []
    var filterincomes: [String] = []
    var filterspendings: [String] = []
    var filterrating: [String] = []
    var filtericon: [String] = []
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RankTableViewCell
 
        
        cell.nameLabel.text = filterData[indexPath.row]
        cell.emailLabel.text = filteremail[indexPath.row]
        cell.rankLabel.text = filterranking[indexPath.row]
        
        if icon[indexPath.row].elementsEqual("none")  {}
        else {
            if let img = cache.object(forKey: self.icon[indexPath.row] as AnyObject) as? UIImage{
                cell.UserIcon.image = img
            }
            else{
                DispatchQueue.global(qos: .default).async{
                    
                    let filepath =  self.icon[indexPath.row]
                    self.storageRef.child(filepath).downloadURL { (url, error) in
                                   guard let dlurl = url else {return}
                                   self.icon[indexPath.row] = dlurl.absoluteString
                               }
                     let myurl = URL(string: self.icon[indexPath.row])
                    print(self.icon[indexPath.row])
                    if let data = try? Data(contentsOf: myurl!){
                        let final_img = UIImage(data:data)
                        self.cache.setObject(final_img!, forKey: self.icon[indexPath.row] as AnyObject)
                        DispatchQueue.main.async{
                          
                            cell.UserIcon.image = final_img
                            
                        }
                    }
                }
            }
        }
        
        
        return cell
        
    }
    
    
    // to call detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "ShowRankSegue" {
            
            let destination = segue.destination as! DetailRankViewController
            let rankindex = table.indexPathForSelectedRow?.row
            
            // the following are to pass the selected user data to detailrankview
            destination.name = filterData[rankindex!]
            destination.Sranking = filterranking[rankindex!]
            destination.Ssaving = filterincomes[rankindex!]
            destination.Sspending = filterspendings[rankindex!]
            destination.Srating = filterrating[rankindex!]
            //print(incomes)
            // print(spendings)
            print(icon)
            
        }
    }
    
    // Update filterdata when user type in searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData = searchText.isEmpty ? items : items.filter({(dataString: String) -> Bool in return dataString.range(of: searchText, options: .caseInsensitive) != nil })
        
        filteremail = []
        filterincomes = []
        filterrating = []
        filterranking = []
        filterspendings = []
        var isfound = false
        
        for info in filterData {
            for i in 0 ... items.count {
                
                if info == items[i] && isfound == false {
                    filterincomes.append(incomes[i])
                    filterspendings.append(spendings[i])
                    filterrating.append(rating[i])
                    filteremail.append(email[i])
                    filterranking.append(ranking[i])
                    print(filterranking)
                    isfound = true
                    break
                }
                isfound = false
            }
        }
        table.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DatabaseUtil.data.getAllUser(completion:{(names,emails,ranking,income,spending,rating,usericon) in
            self.items = names
            self.email = emails
            self.ranking = ranking
            self.incomes = income
            self.spendings = spending
            self.rating = rating
            self.table.reloadData()
            
            //retrieve icon
            
            self.icon = usericon
            
        })
        self.filterData = self.items
        self.filteremail = self.email
        self.filterranking = self.ranking
        self.filterspendings = self.spendings
        self.filterrating = self.rating
        self.filterincomes = self.incomes
        self.table.reloadData()
        
        filterData = self.items
        //     filteremail = self.email
        // filterranking = self.ranking
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        table.dataSource = self
        searchBar.delegate = self
        
        storage = Storage.storage()
        storageRef = storage.reference()
        
        // the following is uses to search the users with their data
        DatabaseUtil.data.getAllUser(completion:{(names,emails,ranking,income,spending,rating,usericon) in
            self.items = names
            self.email = emails
            self.ranking = ranking
            self.incomes = income
            self.spendings = spending
            self.rating = rating
            self.icon = usericon
            
            
           
        })
        self.filterData = self.items
        
        
        self.table.reloadData()
        
        filterData = self.items
        table.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func displayErrorMessage (title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: false, completion: nil)
    }
    
    
}

