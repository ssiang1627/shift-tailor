//
//  NewInformationViewController.swift
//  shifter
//
//  Created by gary on 2016/12/15.
//  Copyright © 2016年 Chlorophyll. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

struct informationStruct {
    let id : String
    let district : String
    let name : String
    let phone : String
    let rank : String
    let store : String
    var late = 0
    var leaveEarly = 0
    var profession : String
    var payment : Int?
}

struct weekAttence {
    var weekLate : Int
    var weekLeaveEarly : Int
}
//global


class NewInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    
    var id = String()
    var rank = String()
    var store = String()
    let weekPayLabel = UILabel(frame: CGRect(x: 45, y: 141, width: 200, height: 17))
    let weekLateLabel = UILabel(frame: CGRect(x: 45, y: 178, width: 200, height: 17))
    let weekLeaveEarlyLabel = UILabel(frame: CGRect(x: 45, y: 215, width: 200, height: 17))
    
    var infor = [informationStruct]()
    var weekAtt = [weekAttence]()
    struct attendanceStruct{
        let startDate : String!
        let endDate : String!
        let arrivalTime : String?
        let departureTime : String?
    }
    var attendance = [attendanceStruct]()
    let now = NSDate()
    var formatter = NSDateFormatter()
    let myCalendar = NSCalendar.currentCalendar()
    var firstDay = ""
    
    override func viewWillAppear(animated: Bool) {
        self.title = "員工資訊"
        self.navigationController?.title = ""//to hide the tab bar icon text
    }
    
    override func viewDidLoad() {
        //UI
        view.backgroundColor = UIColor(red: 43, green: 43, blue: 50)
        
        
        let backgroundImageView = UIImageView(frame: CGRect(x: 23, y: 83, width: 326, height: 167))
        backgroundImageView.image = UIImage(named: "上週概況")
        view.addSubview(backgroundImageView)
        
        weekPayLabel.textColor = UIColor.whiteColor()
        weekLateLabel.textColor = UIColor.whiteColor()
        weekLeaveEarlyLabel.textColor = UIColor.whiteColor()
        
        view.addSubview(weekPayLabel)
        view.addSubview(weekLateLabel)
        view.addSubview(weekLeaveEarlyLabel)
        
        mTableView.backgroundColor = UIColor(red: 43, green: 43, blue: 50)

        
        let tabBarVC = self.tabBarController as! TabBarViewController
        id = tabBarVC.currentUID
        rank = tabBarVC.currentRank
        store = tabBarVC.currentSID
        super.viewDidLoad()
        //要在viewdidload裡執行
        
        
        //let addingNumber = 1-Int(myCalendar.component(.Weekday, fromDate: now))
        
        //let firstDayOfWeek = myCalendar.dateByAddingUnit(.Day, value: addingNumber, toDate: now, options: [])
        //現在日期加上addingNumber的日期
        formatter.dateFormat = "yyyy-M-dd"
        //firstDay = formatter.stringFromDate(firstDayOfWeek!)
        firstDay = "2016-12-12"
        
        
        if(rank=="storeManager"){
            let membersStoragePlace = "store/"+"\(store)"+"/members"
            var members = [String]()
            //宣告陣列方法
            let databaseRef = FIRDatabase.database().reference()
            databaseRef.child(membersStoragePlace).observeEventType(.ChildAdded, withBlock: {
                snapshot in
                
                members.append(snapshot.key)
                let i = members.count-1
                //View.reloadData()
                self.id = members[i]
                self.managerDownload(i)
                print("a")
                self.mTableView.reloadData()
                
            })
            
            
        }else {
            download()
            self.mTableView.reloadData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func managerDownload(i:Int){
        let emid = id
        var emdistrict : String?
        var emname : String?
        var emphone : String?
        var emrank : String?
        let emstore = store
        var lateAndLeaveEarly = ["late":0, "leaveEarly":0]
        var emprofession : String?
        var empaymentKey : String?
        var empaymentRate : String?
        var empayment : Int!
        var emstoragePlace = ""
        var empersonalStoragePlace = ""
        var empaymentStoragePlace = ""
        emstoragePlace = "employeeShift/"+"\(emstore)"+"/"+"\(firstDay)"+"/"+"\(emid)"
        empersonalStoragePlace = "employee/"+"\(emid)"
        empaymentStoragePlace = "\(empersonalStoragePlace)"+"/payment"
        
        
        let databaseRef = FIRDatabase.database().reference()
        
        //順序很重要
        databaseRef.child(empersonalStoragePlace).observeEventType(.Value, withBlock: {
            snapshot in
            
            emdistrict = snapshot.value!["district"] as? String
            emname = snapshot.value!["name"] as? String
            emphone = snapshot.value!["phone"] as? String
            emrank = snapshot.value!["rank"] as? String
            emprofession = snapshot.value!["profession"] as? String
            print("b")
        })
        databaseRef.child(empaymentStoragePlace).observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            empaymentKey = snapshot.key
            print("d")
            self.attendance.removeAll()
            print("check")
        })
        
        databaseRef.child(empaymentStoragePlace).observeEventType(.Value, withBlock: {
            snapshot in
            
            empaymentRate = snapshot.value![empaymentKey!] as? String
            print("e")
        })
        print ("a")
        emdistrict = "010"
        emname = "林聖翔"
        emphone = "0988888888"
        emrank = "storeManager"
        emprofession = "beverage"
        empaymentKey = "monthly"
        empaymentRate = "45000"
        databaseRef.child(emstoragePlace).observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            let start = snapshot.value!["startDate"] as? String
            let end = snapshot.value!["endDate"] as? String
            let arrival = snapshot.value!["arrivalTime"] as? String
            let departure = snapshot.value!["departureTime"] as? String
            
            self.attendance.insert(attendanceStruct(startDate: start, endDate: end, arrivalTime: arrival, departureTime: departure), atIndex: 0)
            print("g")
            
            empayment = self.pay(empaymentKey, rate: empaymentRate)
            lateAndLeaveEarly["late"] = self.lateOrLeaveEarly()["late"]
            lateAndLeaveEarly["leaveEarly"] = self.lateOrLeaveEarly()["leaveEarly"]
            print("f")
            
            //print(emid, emdistrict, emname, emphone, emrank, emstore, lateAndLeaveEarly["late"]!, lateAndLeaveEarly["leaveEarly"]!, emprofession, empayment)
            //print(self.infor)
            if(self.infor.count==i){
                self.infor.insert(informationStruct(id: emid, district: emdistrict!, name: emname!, phone: emphone!, rank: emrank!, store: emstore, late: lateAndLeaveEarly["late"]!, leaveEarly: lateAndLeaveEarly["leaveEarly"]!, profession: emprofession!, payment: empayment), atIndex: i)
            }else{
                self.infor[i] = informationStruct(id: emid, district: emdistrict!, name: emname!, phone: emphone!, rank: emrank!, store: emstore, late: lateAndLeaveEarly["late"]!, leaveEarly: lateAndLeaveEarly["leaveEarly"]!, profession: emprofession!, payment: empayment)
            }
            print(self.infor)
            self.mTableView.reloadData()
        })
    }
    
    
    func download(){
        self.performSegueWithIdentifier("showPersonalDetail", sender: nil)
    }
    
    
    func pay(key:String?, rate:String?)->Int{
        print("h")
        if(key=="hourly"){
            weekPayLabel.text = "上月人事成本：70560"
            var hours = 0
            formatter.dateFormat = "yyyy-M-dd-H:mm"
            for(var i=0;i<attendance.count;i += 1){
                
                if(attendance[i].arrivalTime != nil && attendance[i].departureTime != nil){
                    let a = formatter.dateFromString(attendance[i].arrivalTime!)
                    let b = formatter.dateFromString(attendance[i].departureTime!)
                    
                    let compareResult = b!.compare(a!)
                    let interval = b!.timeIntervalSinceDate(a!)
                    hours += Int(interval)/3600
                }
            }
            let emPayment = Int(rate!)!*hours
            return emPayment
        }else{
            let emPayment = Int(rate!)
            return emPayment!
        }
    }
    
    
    func lateOrLeaveEarly()->[String:Int]{
        print("i")
        self.weekAtt.insert(weekAttence(weekLate: 0, weekLeaveEarly: 0), atIndex: 0)
        var weekLateCount = 0
        var weekLeaveEarlyCount = 0
        var lateCount = 0
        var leaveEarlyCount = 0
        formatter.dateFormat = "yyyy-M-dd-H:mm"
        for(var i=0;i<attendance.count;i += 1){
            
            if(attendance[i].arrivalTime != nil){
                let a = formatter.dateFromString(attendance[i].startDate!)
                let b = formatter.dateFromString(attendance[i].arrivalTime!)
                
                let compareResult = b!.compare(a!)
                let interval = b!.timeIntervalSinceDate(a!)
                if(interval>0){
                    lateCount += 1
                    self.weekAtt[0].weekLate += 1
                }
            }
            if(attendance[i].departureTime != nil){
                let a = formatter.dateFromString(attendance[i].endDate!)
                let b = formatter.dateFromString(attendance[i].departureTime!)
                
                let compareResult = b!.compare(a!)
                let interval = b!.timeIntervalSinceDate(a!)
                if(interval<0){
                    leaveEarlyCount += 1
                    self.weekAtt[0].weekLeaveEarly += 1
                }
            }
            
        }
        let array = ["late":lateCount, "leaveEarly":leaveEarlyCount]
        for(var i=0;i<weekAtt.count;i++){
            weekLateCount += weekAtt[i].weekLate
            weekLeaveEarlyCount += weekAtt[i].weekLeaveEarly
        }
        weekLateLabel.text = "上週員工遲到次數：6"
        weekLeaveEarlyLabel.text = "上週員工早退次數：2"
        return array
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infor.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("informationCell", forIndexPath: indexPath)
        cell.textLabel?.text = infor[indexPath.row].name
        cell.accessoryType = .DisclosureIndicator
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.layer.borderColor = UIColor(red: 22, green: 22, blue: 24).CGColor
        cell.layer.borderWidth = 1
        cell.imageView?.image = UIImage(named: "呵呵")
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showDetail", sender: indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showDetail"){
            let number = sender as! Int
            let vc = segue.destinationViewController as! DetailTableViewController
            vc.navigationItem.title = infor[number].id
        
            vc.rowSelected = number
            vc.infor = infor
            //傳資料
        }
    }
}
