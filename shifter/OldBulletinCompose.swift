//
//  BulletinCompose.swift
//  shifter
//
//  Created by Frank Wang on 2016/8/25.
//  Copyright © 2016年 Chlorophyll. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class OldBulletinCompose: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var inputTitle = String()
    var inputTime = String()
    var inputContent = String()
    var indexPathArray = [NSIndexPath]()
    var sectionPressed = Int()
    var editMode = Bool()
    var selectedSection = Int()
    var selectedRow = Int()
    var section0Posts = [post]()
    var section1Posts = [post]()
    var section0Refs = [AnyObject]()
    var section1Refs = [AnyObject]()
    var didSelectDateCell = Bool()
    var firstLoad = Bool()
    var currentUID = String()
    var currentSID = String()
    var currentDID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新增公告"
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(OldBulletinCompose.donePressed))
        doneButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = doneButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(OldBulletinCompose.cancelPressed))
        cancelButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = cancelButton
        firstLoad = true
        self.tabBarController?.tabBar.hidden = true
        
        tableView.registerNib(UINib(nibName: "DateTableViewCell", bundle: nil), forCellReuseIdentifier: "dateCell")

        
        //get value from tab bar VC
        let tabBarVC = self.tabBarController as! TabBarViewController
        currentUID = tabBarVC.currentUID
        currentSID = tabBarVC.currentSID
        currentDID = tabBarVC.currentDID

        //set data for edit mode
        if editMode == true{
            
            //get value from tab bar VC
            section0Posts = tabBarVC.section0Posts
            section1Posts = tabBarVC.section1Posts
            section0Refs = tabBarVC.section0Refs
            section1Refs = tabBarVC.section1Refs
            selectedSection = tabBarVC.selectedSection
            selectedRow = tabBarVC.selectedRow
            
            if selectedSection == 0{
                inputTitle = section0Posts[selectedRow].title
                inputTime = section0Posts[selectedRow].time
                inputContent = section0Posts[selectedRow].content
            }else{
                inputTitle = section1Posts[selectedRow].title
                inputTime = section1Posts[selectedRow].time
                inputContent = section1Posts[selectedRow].content
            }
            
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if editMode == false{
            sectionPressed = 0
        }else{
            sectionPressed = selectedSection
        }
    }


    
    @IBOutlet weak var tableView: UITableView!
    
    //set tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if editMode == false{
            return 4
        }else{
            return 5
        }
    }
    
    //add label func
    func addSubjectLabel(cell: UITableViewCell ,subject: String){
        let subjectLabel = UILabel(frame: CGRectMake(20,10,51,21))
        cell.addSubview(subjectLabel)
        subjectLabel.text = subject
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let textInputCell = tableView.dequeueReusableCellWithIdentifier("textInputCell") as? TextInputTableViewCell
        let dateCell = tableView.dequeueReusableCellWithIdentifier("dateCell") as? DateTableViewCell
        //get NSIndexPath for later synchronization
        for row in 0...2{
            indexPathArray.append(NSIndexPath(forRow: row, inSection: 0))
        }
        
        
        if editMode == false{
            if indexPath.row == 0{
                addSubjectLabel(textInputCell!, subject: "標題：")
                textInputCell!.configure(text: inputTitle, placeholder: "title")
                textInputCell!.textInput.delegate = self
                textInputCell?.textInput.becomeFirstResponder()
                return textInputCell!
            }else if indexPath.row == 1{
                addSubjectLabel(dateCell!, subject: "時間：")
                if didSelectDateCell == false{
                    dateCell?.datePicker.hidden = true
                }else{
                    dateCell?.datePicker.hidden = false
                }
                dateCell?.setLabel(NSDateFormatter.localizedStringFromDate(dateCell!.datePicker.date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)) //set default date(current time)
                return dateCell!
            }else if indexPath.row == 2{
                addSubjectLabel(textInputCell!, subject: "內容：")
                textInputCell!.configure(text: inputContent, placeholder: "content")
                textInputCell!.textInput.delegate = self
                return textInputCell!
            }else{
                addSubjectLabel(cell, subject: "種類：")

                //add buttons
                let type1Button = UIButton(frame: CGRect(x: 70,y: 8,width: 46,height: 30))
                type1Button.setTitle("店", forState: .Normal)
                type1Button.setTitleColor(.blackColor(), forState: .Normal)
                type1Button.setTitleColor(UIColor.blueColor() , forState: .Selected)
                type1Button.tag = 1
                type1Button.addTarget(self, action: #selector(OldBulletinCompose.sectionPressed(_:)), forControlEvents: .TouchUpInside)
                cell.contentView.addSubview(type1Button)
                
                let type2Button = UIButton(frame: CGRect(x: 140,y: 8,width: 46,height: 30))
                type2Button.setTitle("區", forState: .Normal)
                type2Button.setTitleColor(.blackColor(), forState: .Normal)
                type2Button.tag = 2
                type2Button.addTarget(self, action: #selector(OldBulletinCompose.sectionPressed(_:)), forControlEvents: .TouchUpInside)
                cell.contentView.addSubview(type2Button)
                
                if sectionPressed == 0{
                    type1Button.backgroundColor = .grayColor()
                    type2Button.backgroundColor = .whiteColor()
                }else{
                    type1Button.backgroundColor = .whiteColor()
                    type2Button.backgroundColor = .grayColor()
                }
                return cell
            }

        }else{
            
            if indexPath.row == 0{
                addSubjectLabel(textInputCell!, subject: "標題：")
                if selectedSection == 0{
                    textInputCell!.configure(text: inputTitle, placeholder: "Title")
                }else{
                    textInputCell!.configure(text: inputTitle, placeholder: "Title")
                }
                textInputCell!.textInput.delegate = self
                return textInputCell!
            }else if indexPath.row == 1{
                addSubjectLabel(dateCell!, subject: "時間：")
                if didSelectDateCell == false{
                    dateCell?.datePicker.hidden = true
                }else{
                    dateCell?.datePicker.hidden = false
                }
                dateCell?.setLabel(inputTime) //set default date(saved date)
                return dateCell!
            }else if indexPath.row == 2{
                addSubjectLabel(textInputCell!, subject: "內容：")
                if selectedSection == 0{
                    textInputCell!.configure(text: inputContent, placeholder: "Content")
                }else{
                    textInputCell!.configure(text: inputContent, placeholder: "Content")
                }
                textInputCell!.textInput.delegate = self
                return textInputCell!
            }else if indexPath.row == 3{
                addSubjectLabel(cell, subject: "種類：")
                
                //add buttons
                let type1Button = UIButton(frame: CGRect(x: 70,y: 8,width: 46,height: 30))
                type1Button.setTitle("店", forState: .Normal)
                type1Button.setTitleColor(.blackColor(), forState: .Normal)
                type1Button.setTitleColor(UIColor.blueColor() , forState: .Selected)
                type1Button.tag = 1
                type1Button.addTarget(self, action: #selector(OldBulletinCompose.sectionPressed), forControlEvents: .TouchUpInside)
                cell.contentView.addSubview(type1Button)
                
                let type2Button = UIButton(frame: CGRect(x: 140,y: 8,width: 46,height: 30))
                type2Button.setTitle("區", forState: .Normal)
                type2Button.setTitleColor(.blackColor(), forState: .Normal)
                type2Button.tag = 2
                type2Button.addTarget(self, action: #selector(OldBulletinCompose.sectionPressed), forControlEvents: .TouchUpInside)
                cell.contentView.addSubview(type2Button)
                
                if sectionPressed == 0{
                    type1Button.backgroundColor = .grayColor()
                    type2Button.backgroundColor = .whiteColor()
                }else{
                    type1Button.backgroundColor = .whiteColor()
                    type2Button.backgroundColor = .grayColor()
                }
                return cell
            }else{
                let deleteButton = UIButton(frame: CGRect(x: 47, y: 7, width: 281, height: 30))
                deleteButton.setTitle("Delete", forState: .Normal)
                deleteButton.setTitleColor(.whiteColor(), forState: .Normal)
                deleteButton.backgroundColor = .redColor()
                deleteButton.addTarget(self, action: #selector(OldBulletinCompose.deletePressed), forControlEvents: .TouchUpInside)
                cell.contentView.addSubview(deleteButton)
                
                return cell
            }

        }
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1{
            if didSelectDateCell == false{
                didSelectDateCell = true
            }else{
                didSelectDateCell = false
            }
        }else{
            didSelectDateCell = false
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadRowsAtIndexPaths([indexPathArray[1]], withRowAnimation: .Automatic)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 {
            if didSelectDateCell == true{
                return 132
            }else{
                return 44
            }
        }else{
            return 44
        }
    }
    
    //func to synchronize value
    func saveInputText(){
        let titleCell = tableView.cellForRowAtIndexPath(indexPathArray[0]) as! TextInputTableViewCell
        let timeCell = tableView.cellForRowAtIndexPath(indexPathArray[1]) as! DateTableViewCell
        let contentCell = tableView.cellForRowAtIndexPath(indexPathArray[2]) as! TextInputTableViewCell
        inputTitle = titleCell.textInput.text!
        inputTime = timeCell.dateLabel.text!
        inputContent = contentCell.textInput.text!

    }
    

    //save value when textfield's value changed
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        saveInputText()
        return true
    }
    
    //choose section
    func sectionPressed(sender:UIButton){
        if sender.tag == 1{
            sectionPressed = 0
        }else{
            sectionPressed = 1
        }
        
        //update to latest value in textfield
        saveInputText()
        tableView.reloadData()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {  //press return
        textField.resignFirstResponder()
        return true
    }

    func donePressed(){
        if editMode == false{
            //update to latest value in textfield
            saveInputText()
            
            //save input to post
            let post : [String : AnyObject] = ["title" : inputTitle, "time" : inputTime, "content" : inputContent, "section" : sectionPressed, "employee" : currentUID, "store" : currentSID, "district" : currentDID]
            
            //make reference to Firebase database
            let databaseRef = FIRDatabase.database().reference()
            
            //add child "Posts" and upload post with auto ID
            databaseRef.child("bulletin").childByAutoId().setValue(post)

        }else{
            saveInputText()
            
            let databaseRef = FIRDatabase.database().reference()
            
            if selectedSection == 0{
                databaseRef.child("bulletin").child(section0Refs[selectedRow] as! String).updateChildValues(["title" : inputTitle, "time" : inputTime, "content" : inputContent, "section" : sectionPressed, "employee" : currentUID, "store" : currentSID, "district" : currentDID])
            }else{
                databaseRef.child("bulletin").child(section1Refs[selectedRow] as! String).updateChildValues(["title" : inputTitle, "time" : inputTime, "content" : inputContent, "section" : sectionPressed, "employee" : currentUID, "store" : currentSID, "district" : currentDID])
            }
            
        }
       
        //go back to bulletin without losing tab bar and navigation controller
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    func cancelPressed(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func deletePressed(){
        let databaseRef = FIRDatabase.database().reference()
        
        if selectedSection == 0{
            databaseRef.child("bulletin").child(section0Refs[selectedRow] as! String).removeValue() //remove from database
        }else{
            
            databaseRef.child("bulletin").child(section1Refs[selectedRow] as! String).removeValue()
        }

        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}









