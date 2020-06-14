//
//  BlogDetailViewController.swift
//  Millionare
//
//  Created by Michael Chan on 13/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit

class BlogDetailViewController: UIViewController {
    var blogIcon=String()
    var blogTitle=String()
    var blogContent=String()
    var cache=NSCache<AnyObject,AnyObject>()
    
    @IBOutlet var mTitle: UILabel!
    
    @IBOutlet var mIcon: UIImageView!
    
    @IBOutlet var mContent: UITextView!
    
    @IBAction func exitBtn(_ sender: Any) {
        
        self.dismiss(animated:true, completion:nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        mTitle.text=blogTitle
        mContent.text=blogContent
      if let img = cache.object(forKey: blogIcon as AnyObject) as? UIImage{
            mIcon.image = img
            
        }else{
        DispatchQueue.global(qos: .default).async{
            
            let myurl = URL(string: self.blogIcon)
            let data = try? Data(contentsOf: myurl!)
            let final_img = UIImage(data:data!)
            self.cache.setObject(final_img!, forKey: self.blogIcon as AnyObject)
            DispatchQueue.main.async{
                self.mIcon.image = final_img
            }
        }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
