//
//  PopoverViewController.swift
//  need2pee
//
//  Created by hdm on 07/04/16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {

    @IBOutlet weak var applyFilterBtn: UIButton!
    
    @IBOutlet weak var barrierFreeSwitchOutlet: UISwitch!
    
    @IBOutlet weak var freeSwitchOutlet: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyFilterBtn.layer.cornerRadius = 5
        
        //Loading the previously entered switch states into the switches
        freeSwitchOutlet.on =  NSUserDefaults.standardUserDefaults().boolForKey("switchStateCost")
        barrierFreeSwitchOutlet.on =  NSUserDefaults.standardUserDefaults().boolForKey("switchStateBarrier")
    }
    
    /**
     Sets the values for the switches in order to save them for the popover's next appearal
     */
    @IBAction func applyFilterBtn(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(freeSwitchOutlet.on, forKey: "switchStateCost")
        
        NSUserDefaults.standardUserDefaults().setBool(barrierFreeSwitchOutlet.on, forKey: "switchStateBarrier")
        print("------------------------")
    }
    
    /**
     Fetches the boolean indicating whether a toilet is cost-free
     
     - returns:
     A boolean indicating whether a toilet is cost-free
     */
    func getFree() -> Bool {
        return freeSwitchOutlet?.on ?? NSUserDefaults.standardUserDefaults().boolForKey("switchStateCost")
    }
    
    /**
     Fetches the boolean indicating whether a toilet is barrier-free
     
     - returns:
     A boolean indicating whether a toilet is barrier-free
     */
    func getBarrierFree() -> Bool {
        return barrierFreeSwitchOutlet?.on ?? NSUserDefaults.standardUserDefaults().boolForKey("switchStateBarrier")
    }
}
