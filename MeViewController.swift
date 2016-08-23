//
//  MeViewController.swift
//  hoBshare
//
//  Created by Miguel Melendez on 8/5/16.
//  Copyright © 2016 Miguel Melendez. All rights reserved.
//

import UIKit
import MapKit

class MeViewController: HoBshareViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var curLatLabel: UILabel!
    @IBOutlet weak var curLonLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.delegate = self

    }

    override func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        super.locationManager(manager, didUpdateLocations: locations) // Make sure to call super's implementation so that we get its behavior and current location gets set.
        
        curLatLabel.text = "Latitude: \(currentLocation!.coordinate.latitude)"
        curLonLabel.text = "Longitude: \(currentLocation!.coordinate.longitude)"

    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if validate() {
            submit()
        }
        
        return true
    }
    
    func validate() -> Bool {
        var valid = false
        
        if username.text != nil && username.text?.characters.count > 0
        {
            valid = true
        }
        else
        {
            self.showError("Did you enter a username?")
        }
        
        return valid
    }
    
    func submit() {
        username.resignFirstResponder()
        let requestUser = User(userName: username.text!) // Force unwrap possible because we've already validated the form! =)
        
        requestUser.latitude =  currentLocation?.coordinate.latitude
        requestUser.longitude =  currentLocation?.coordinate.longitude
        
        UserDP().getAccountForUser(requestUser) { (returnedUser) in
            if (returnedUser.status.code == 0)
            {
                self.myHobbies = returnedUser.hobbies
                
                NSUserDefaults.standardUserDefaults().setValue(returnedUser.userId, forKey: "CurrentUserId")
                NSUserDefaults().synchronize()
            }
            else
            {
                self.showError(returnedUser.status.statusDescription!)
            }
        }
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        if validate() { submit() }
    }

}