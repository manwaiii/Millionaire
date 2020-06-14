//
//  StatisticsViewController.swift
//  Millionare
//
//  Created by Kanon on 7/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit
import Charts
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class StatisticsViewController: UIViewController {
    
    
    
    var refUser: DatabaseReference!
    var storageRef: StorageReference!
    var storage: Storage!
    var monthFlag = true
    var weekFlag = false
    var dayFlag = false
    
    var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var category: [String]!
    
    var sevenDaysDouble: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    
    
    var spendingList = [SpendingModel]()

    @IBOutlet var lineChart: LineChartView!
    @IBOutlet var pieChart: PieChartView!
    
    @IBOutlet var monthWeekDay: UISegmentedControl!
    @IBAction func MonthWeekDay(_ sender: Any) {
        lineChart.clear()
        pieChart.clear()
        if monthWeekDay.selectedSegmentIndex == 0{
            monthFlag = true
            weekFlag = false
            dayFlag = false
        } else if monthWeekDay.selectedSegmentIndex == 1{
            monthFlag = false
            weekFlag = true
            dayFlag = false
        } else {
            monthFlag = false
            weekFlag = false
            dayFlag = true
        }
        chartDataFromFB()
    }
    
    override func viewDidLoad() {
        
        chartDataFromFB()
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // abc
    }
    
    func chartDataFromFB(){
        storage = Storage.storage()
        storageRef = storage.reference()
        refUser = Database.database().reference().child("user");
        // Do any additional setup after loading the view.
        let user = Auth.auth().currentUser
        let userID = user?.uid
        
        //generating a new key inside artists node
        //and also getting the generated key
        refUser = Database.database().reference().child("spending").child(String(userID!))
        
        refUser.observe(.value, with: {  (snapshot) in
            //if the reference have some values
            if snapshot.childrenCount > 0 {

                self.spendingList.removeAll()

                //iterating through all the values
                for records in snapshot.children {
                    //getting values
                    let spendings = records as! DataSnapshot
                    
                    let spendingObject = spendings.value as? [String: AnyObject]
                    let spendingYear  = spendingObject?["year"]
                    let spendingMonth  = spendingObject?["month"]
                    let spendingDay = spendingObject?["day"]
                    let spendingValue = spendingObject?["value"]
                    let spendingCategory = spendingObject?["category"]
                    let spendingUserID = spendingObject?["userID"]
                    let spendingTitle = spendingObject?["title"]
                    let spendingID = spendingObject?["id"]
                    
                    
                    //creating artist object with model and fetched values
                    let spending = SpendingModel(userID: spendingUserID as! String?, title: spendingTitle as! String?, value: spendingValue as! String?, day: spendingDay as! String?, month: spendingMonth as! String?, year: spendingYear as! String?, category: spendingCategory as! String?, id: spendingID as! String?)
                    
                    //appending it to list
                    self.spendingList.append(spending)
                }
                
                if self.monthFlag{
                    self.monthLineChartGen()
                    self.monthPieChartGen()
                } else if self.weekFlag{
                    self.weekLineChartGen()
                    self.weekPieChartGen()
                } else {
                    self.dayLineChartGen()
                    self.dayPieChartGen()
                }
                
            }

        })
        
    }
    
    func monthLineChartGen(){
        let date = Date()
        let calendar = Calendar.current
        let currentYear = String(calendar.component(.year, from: date))
        
        var monthValue: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        for spending in spendingList{
            if spending.year == currentYear{
                switch spending.month {
                case "1":
                    monthValue[0] += Double(spending.value!)!
                    break
                case "2":
                    monthValue[1] += Double(spending.value!)!
                    break
                case "3":
                    monthValue[2] += Double(spending.value!)!
                    break
                case "4":
                    monthValue[3] += Double(spending.value!)!
                    break
                case "5":
                    monthValue[4] += Double(spending.value!)!
                    break
                case "6":
                    monthValue[5] += Double(spending.value!)!
                    break
                case "7":
                    monthValue[6] += Double(spending.value!)!
                    break
                case "8":
                    monthValue[7] += Double(spending.value!)!
                    break
                case "9":
                    monthValue[8] += Double(spending.value!)!
                    break
                case "10":
                    monthValue[9] += Double(spending.value!)!
                    break
                case "11":
                    //print(spending.value!)
                    monthValue[10] += Double(spending.value!)!
                    break
                case "12":
                    monthValue[11] += Double(spending.value!)!
                    break
                default:
                    break
                }
            }
        }
        var dataEntries = [ChartDataEntry]()
        let monthNum = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0]
        
        for i in 0...11 {
            let value = ChartDataEntry(x: monthNum[i] , y: monthValue[i])
            //print(monthValue[i])
            dataEntries.append(value)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Monthly Spending")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        //let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartDataSet.colors = [NSUIColor.green]
        lineChart.data = lineChartData
        lineChart.animate(yAxisDuration: 1.0)
        lineChart.doubleTapToZoomEnabled = false
    }
    
    func weekLineChartGen(){
        var sevenDays: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        var sevenMonths: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        var sevenYears: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        
        var weekValue: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var tmp = 6
        for _ in 0 ... 6 {
            let dayDouble = Double(cal.component(.day, from: date))
            let day = String(cal.component(.day, from: date))
            let month = String(cal.component(.month, from: date))
            let year = String(cal.component(.year, from: date))
            sevenDaysDouble[tmp] = dayDouble
            sevenDays[tmp] = day
            sevenMonths[tmp] = month
            sevenYears[tmp] = year
            date = cal.date(byAdding: .day, value: -1, to: date)!
            tmp = tmp - 1
        }
        
        for spending in spendingList{
            for i in 0...6{
                if spending.year == sevenYears[i] && spending.month == sevenMonths[i] && spending.day == sevenDays[i]{
                    weekValue[i] += Double(spending.value!)!
                }
            }
        }
        
        var dataEntries = [ChartDataEntry]()
        
        for i in 0...6 {
            let value = ChartDataEntry(x: sevenDaysDouble[i] , y: weekValue[i])
            //print(monthValue[i])
            dataEntries.append(value)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Current 7 Days Spending")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        //let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartDataSet.colors = [NSUIColor.red]
        lineChart.data = lineChartData
        lineChart.animate(yAxisDuration: 1.0)
        lineChart.doubleTapToZoomEnabled = false
    }
    
    func dayLineChartGen(){
        var sevenDays: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        var sevenMonths: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        var sevenYears: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        
        var dayValue: [Double] = [0.0, 0.0]
        
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var tmp = 1
        for _ in 0 ... 1 {
            let dayDouble = Double(cal.component(.day, from: date))
            let day = String(cal.component(.day, from: date))
            let month = String(cal.component(.month, from: date))
            let year = String(cal.component(.year, from: date))
            sevenDaysDouble[tmp] = dayDouble
            sevenDays[tmp] = day
            sevenMonths[tmp] = month
            sevenYears[tmp] = year
            date = cal.date(byAdding: .day, value: -1, to: date)!
            tmp = tmp - 1
        }
        
        for spending in spendingList{
            for i in 0...1{
                if spending.year == sevenYears[i] && spending.month == sevenMonths[i] && spending.day == sevenDays[i]{
                    dayValue[i] += Double(spending.value!)!
                }
            }
        }
        
        var dataEntries = [ChartDataEntry]()
        
        for i in 0...1 {
            let value = ChartDataEntry(x: sevenDaysDouble[i] , y: dayValue[i])
            //print(monthValue[i])
            dataEntries.append(value)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Today Spending comparing with Yesterday")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        //let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartDataSet.colors = [NSUIColor.blue]
        lineChart.data = lineChartData
        lineChart.animate(yAxisDuration: 1.0)
        lineChart.doubleTapToZoomEnabled = false
    }
    
    func monthPieChartGen(){
        let date = Date()
        let calendar = Calendar.current
        let currentYear = String(calendar.component(.year, from: date))
        let currentMonth = String(calendar.component(.month, from: date))
        
        var foodFlag = false
        var clothFlag = false
        var trafFlag = false
        var neceFlag = false
        var enterFlag = false
        var othFlag = false
        
        var catIndexNum = -1
        
        var foodIndex = -1
        var clothIndex = -1
        var trafIndex = -1
        var neceIndex = -1
        var enterIndex = -1
        var othIndex = -1
        var categoryList = [String]()
        var monthValue: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        for spending in spendingList{
            if spending.year == currentYear && spending.month == currentMonth{
                switch spending.category {
                case "food":
                    if !foodFlag {
                        foodFlag = true
                        categoryList.append("Food")
                        catIndexNum = catIndexNum + 1
                        foodIndex = catIndexNum
                    }
                    monthValue[foodIndex] += Double(spending.value!)!
                    break
                case "cloth":
                    if !clothFlag {
                        clothFlag = true
                        categoryList.append("Cloth")
                        catIndexNum = catIndexNum + 1
                        clothIndex = catIndexNum
                    }
                    monthValue[clothIndex] += Double(spending.value!)!
                    break
                case "traffic":
                    if !trafFlag {
                        trafFlag = true
                        categoryList.append("Traffic")
                        catIndexNum = catIndexNum + 1
                        trafIndex = catIndexNum
                    }
                    monthValue[trafIndex] += Double(spending.value!)!
                    break
                case "necessary":
                    if !neceFlag {
                        neceFlag = true
                        categoryList.append("Necessary")
                        catIndexNum = catIndexNum + 1
                        neceIndex = catIndexNum
                    }
                    monthValue[neceIndex] += Double(spending.value!)!
                    break
                case "entertainment":
                    if !enterFlag {
                        enterFlag = true
                        categoryList.append("Entertainment")
                        catIndexNum = catIndexNum + 1
                        enterIndex = catIndexNum
                    }
                    monthValue[enterIndex] += Double(spending.value!)!
                    break
                case "others":
                    if !othFlag {
                        othFlag = true
                        categoryList.append("Others")
                        catIndexNum = catIndexNum + 1
                        othIndex = catIndexNum
                    }
                    monthValue[othIndex] += Double(spending.value!)!
                    break
                default:
                    break
                }
            }
        }
        
        var dataEntries = [ChartDataEntry]()
        
        
        for i in 0..<categoryList.count {
            let dataEntry = PieChartDataEntry(value: monthValue[i], label: categoryList[i], data: categoryList[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Monthly Spending in Categories")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        // 4. Assign it to the chart’s data
        pieChart.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0...5 {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        pieChart.animate(yAxisDuration: 1.0)
    }
    
    func weekPieChartGen(){
        var sevenDays: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        var sevenMonths: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        var sevenYears: [String] = ["0", "0", "0", "0", "0", "0", "0"]
        
        var foodFlag = false
        var clothFlag = false
        var trafFlag = false
        var neceFlag = false
        var enterFlag = false
        var othFlag = false
        
        var catIndexNum = -1
        
        var foodIndex = -1
        var clothIndex = -1
        var trafIndex = -1
        var neceIndex = -1
        var enterIndex = -1
        var othIndex = -1
        var categoryList = [String]()
        
        var weekValue: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var tmp = 6
        for _ in 0 ... 6 {
            let dayDouble = Double(cal.component(.day, from: date))
            let day = String(cal.component(.day, from: date))
            let month = String(cal.component(.month, from: date))
            let year = String(cal.component(.year, from: date))
            sevenDaysDouble[tmp] = dayDouble
            sevenDays[tmp] = day
            sevenMonths[tmp] = month
            sevenYears[tmp] = year
            date = cal.date(byAdding: .day, value: -1, to: date)!
            tmp = tmp - 1
        }
        
        for spending in spendingList{
            for i in 0...6{
                if spending.year == sevenYears[i] && spending.month == sevenMonths[i] && spending.day == sevenDays[i]{
                    switch spending.category {
                    case "food":
                        if !foodFlag {
                            foodFlag = true
                            categoryList.append("Food")
                            catIndexNum = catIndexNum + 1
                            foodIndex = catIndexNum
                        }
                        weekValue[foodIndex] += Double(spending.value!)!
                        break
                    case "cloth":
                        if !clothFlag {
                            clothFlag = true
                            categoryList.append("Cloth")
                            catIndexNum = catIndexNum + 1
                            clothIndex = catIndexNum
                        }
                        weekValue[clothIndex] += Double(spending.value!)!
                        break
                    case "traffic":
                        if !trafFlag {
                            trafFlag = true
                            categoryList.append("Traffic")
                            catIndexNum = catIndexNum + 1
                            trafIndex = catIndexNum
                        }
                        weekValue[trafIndex] += Double(spending.value!)!
                        break
                    case "necessary":
                        if !neceFlag {
                            neceFlag = true
                            categoryList.append("Necessary")
                            catIndexNum = catIndexNum + 1
                            neceIndex = catIndexNum
                        }
                        weekValue[neceIndex] += Double(spending.value!)!
                        break
                    case "entertainment":
                        if !enterFlag {
                            enterFlag = true
                            categoryList.append("Entertainment")
                            catIndexNum = catIndexNum + 1
                            enterIndex = catIndexNum
                        }
                        weekValue[enterIndex] += Double(spending.value!)!
                        break
                    case "others":
                        if !othFlag {
                            othFlag = true
                            categoryList.append("Others")
                            catIndexNum = catIndexNum + 1
                            othIndex = catIndexNum
                        }
                        weekValue[othIndex] += Double(spending.value!)!
                        break
                    default:
                        break
                    }
                }
            }
        }
        
        var dataEntries = [ChartDataEntry]()
        
        
        for i in 0..<categoryList.count {
            let dataEntry = PieChartDataEntry(value: weekValue[i], label: categoryList[i], data: categoryList[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Monthly Spending in Categories")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        // 4. Assign it to the chart’s data
        pieChart.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0...5 {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        pieChart.animate(yAxisDuration: 1.0)
    }
    
    func dayPieChartGen(){
        let date = Date()
        let calendar = Calendar.current
        let currentYear = String(calendar.component(.year, from: date))
        let currentMonth = String(calendar.component(.month, from: date))
        let currentDay = String(calendar.component(.day, from: date))
        
        var foodFlag = false
        var clothFlag = false
        var trafFlag = false
        var neceFlag = false
        var enterFlag = false
        var othFlag = false
        
        var catIndexNum = -1
        
        var foodIndex = -1
        var clothIndex = -1
        var trafIndex = -1
        var neceIndex = -1
        var enterIndex = -1
        var othIndex = -1
        var categoryList = [String]()
        var dayValue: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        for spending in spendingList{
            if spending.year == currentYear && spending.month == currentMonth && spending.day == currentDay{
                switch spending.category {
                case "food":
                    if !foodFlag {
                        foodFlag = true
                        categoryList.append("Food")
                        catIndexNum = catIndexNum + 1
                        foodIndex = catIndexNum
                    }
                    dayValue[foodIndex] += Double(spending.value!)!
                    break
                case "cloth":
                    if !clothFlag {
                        clothFlag = true
                        categoryList.append("Cloth")
                        catIndexNum = catIndexNum + 1
                        clothIndex = catIndexNum
                    }
                    dayValue[clothIndex] += Double(spending.value!)!
                    break
                case "traffic":
                    if !trafFlag {
                        trafFlag = true
                        categoryList.append("Traffic")
                        catIndexNum = catIndexNum + 1
                        trafIndex = catIndexNum
                    }
                    dayValue[trafIndex] += Double(spending.value!)!
                    break
                case "necessary":
                    if !neceFlag {
                        neceFlag = true
                        categoryList.append("Necessary")
                        catIndexNum = catIndexNum + 1
                        neceIndex = catIndexNum
                    }
                    dayValue[neceIndex] += Double(spending.value!)!
                    break
                case "entertainment":
                    if !enterFlag {
                        enterFlag = true
                        categoryList.append("Entertainment")
                        catIndexNum = catIndexNum + 1
                        enterIndex = catIndexNum
                    }
                    dayValue[enterIndex] += Double(spending.value!)!
                    break
                case "others":
                    if !othFlag {
                        othFlag = true
                        categoryList.append("Others")
                        catIndexNum = catIndexNum + 1
                        othIndex = catIndexNum
                    }
                    dayValue[othIndex] += Double(spending.value!)!
                    break
                default:
                    break
                }
            }
        }
        
        var dataEntries = [ChartDataEntry]()
        
        
        for i in 0..<categoryList.count {
            let dataEntry = PieChartDataEntry(value: dayValue[i], label: categoryList[i], data: categoryList[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Monthly Spending in Categories")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        // 4. Assign it to the chart’s data
        pieChart.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0...5 {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        pieChart.animate(yAxisDuration: 1.0)
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
