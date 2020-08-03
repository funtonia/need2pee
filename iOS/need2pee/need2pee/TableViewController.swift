//
//  TableViewController.swift
//  need2pee
//
//  Created by Schlaue Füchse on 29.03.16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

class TableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var tableViewDetail: UITableView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var barrierFreeSwitch: UISwitch!

    @IBOutlet weak var costSwitch: UISwitch!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    //Save button (this Outlet is used to disable and enable the Button)
    @IBOutlet weak var saveBtn: UIButton!
    
    //The limit needed for the input field in which the user writes the toilet's name
    let limitLength = 20
    
    //The latitude and longitude of the user's current location
    var passLongitude: Double!
    var passLatitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        
        //Styling the buttons
        cancelBtn.layer.cornerRadius = 5
        saveBtn.layer.cornerRadius = 5
    }
  
    @IBAction func nameTextField(sender: UITextField) {
        if sender.text == "" {
            //The input field is empty; the saveButton is disabled
            changeButtonStyle(false)
            changeTextFieldStyle(false, textField: nameTextField)
        } else if sender.text!.characters.count > 25{
            //The input field contains more than 25 characters; the saveButton is disabled
            changeButtonStyle(false)
            changeTextFieldStyle(false, textField: nameTextField)
            
            Model.model.showToastMessage("Maximum 25 characters", view: tableViewDetail, yCoordinate: 137, height: 80)
            
        } else if descriptionTextField.text?.characters.count <= 30{
            if Model.model.testUniqueness(sender.text!) {
                changeButtonStyle(true)
                changeTextFieldStyle(true, textField: nameTextField)
            } else {
                Model.model.showToastMessage("The name already exists", view: tableViewDetail, yCoordinate: 137, height: 80)
                changeButtonStyle(false)
                changeTextFieldStyle(false, textField: nameTextField)
            }
        }
    }

    @IBAction func descriptionTextField(sender: AnyObject) {
        if sender.text!.characters.count > 30 {
            //The input field contains more than 30 characters; the saveButton is disabled
            changeButtonStyle(false)
            changeTextFieldStyle(false, textField: descriptionTextField)
            Model.model.showToastMessage("Maximum 30 characters", view: tableViewDetail, yCoordinate: 137, height: 80)
        } else if nameTextField.text?.characters.count <= 25 && nameTextField.text != ""{
            changeTextFieldStyle(true, textField: descriptionTextField)
            changeButtonStyle(true)
        } else {
            changeTextFieldStyle(true, textField: descriptionTextField)
        }
    }
    
    /**
     Saves the user input by calling the saveToilet(...) method from the Model-class
     */
    @IBAction func saveBtn(sender: AnyObject) {
        let nameInput = nameTextField.text!
        let descrInput = descriptionTextField!.text!
        let costInput = costSwitch!.on
        let barrierFreeInput = barrierFreeSwitch!.on
        Model.model.saveToilet(nameInput, descr: descrInput, free: costInput, barrierFree: barrierFreeInput, longitude: passLongitude, latitude: passLatitude)
    }
    
    /**
     * Called when 'return' key is pressed so the keyboard closes
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Changes the text fields' styles
     
     - parameters:
        - correct: boolean indicating whether the user input is correct
        - textfield: the textfield of which the style should be changed
     */
    func changeButtonStyle(correct: Bool){
        if(correct){
            saveBtn.enabled = true
            saveBtn.backgroundColor = UIColor( red: CGFloat(208/255.0), green: CGFloat(147/255.0), blue: CGFloat(0/255.0), alpha: CGFloat(1.0) )
        } else {
            saveBtn.enabled = false
            saveBtn.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    func changeTextFieldStyle(correct: Bool, textField: UITextField) {
        if(correct){
            textField.layer.borderColor = UIColor.clearColor().CGColor
            textField.layer.cornerRadius = 5
            textField.layer.masksToBounds = true
            
            textField.layer.borderWidth = 0.8
        } else {
            textField.layer.cornerRadius = 5
            textField.layer.masksToBounds = true
            textField.layer.borderColor = UIColor(red: 179/255, green: 45/255, blue: 0/255, alpha: 1).CGColor
            
            textField.layer.borderWidth = 0.8
        }

    }
    
}
