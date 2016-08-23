//
//  HoBshareViewController.swift
//  hoBshare
//
//  Created by Miguel Melendez on 8/5/16.
//  Copyright © 2016 Miguel Melendez. All rights reserved.
//

import UIKit
import MapKit

class HoBshareViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var hobbiesCollectionView: UICollectionView!
    
    let availableHobbies: [String : [Hobby]] = HobbyDP().fetchHobbies()
    
    var myHobbies: [Hobby]? {
        
        // This property observer will automatically reload the collection view data whenever this array is updated
        didSet {
            self.hobbiesCollectionView.reloadData()
            self.saveHobbiesToUserDefaults()
        }
    }
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.delegate = self
        
        if(CLLocationManager.authorizationStatus() == .NotDetermined)
        {
            locationManager.requestWhenInUseAuthorization()
        }
        else if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways)
        {
            locationManager.stopUpdatingLocation() // Calling stop before start helps ensure start will actually cause the system to try and get the current location.
            
            locationManager.startUpdatingLocation()
        }
        
        getHobbies()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways
        {
            manager.stopUpdatingLocation()
            manager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFinishDeferedUpdatesWithError error: NSError) {
        print(error.debugDescription)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.debugDescription)
    }
    
    // Collection View Functions
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == hobbiesCollectionView {
            return 1
        }
        else
        {
            return availableHobbies.keys.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hobbiesCollectionView {
            guard myHobbies != nil else
            {
                    return 0
            }
            
            return myHobbies!.count
        }
        else
        {
            let key = Array(availableHobbies.keys)[section]
            
            return availableHobbies[key]!.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: HobbyCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("HobbyCollectionViewCell", forIndexPath: indexPath) as! HobbyCollectionViewCell
        
        if collectionView == hobbiesCollectionView
        {
            let hobby = myHobbies![indexPath.item]
            cell.hobbyLabel.text = hobby.hobbyName
        }
        else
        {
            let key = Array(availableHobbies.keys)[indexPath.section]
            let hobbies = availableHobbies[key]
            let hobby = hobbies![indexPath.item]
            cell.hobbyLabel.text = hobby.hobbyName
        }
        cell.backgroundColor = UIColor.darkGrayColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var availableWidth: CGFloat!
        
        let cellHeight: CGFloat! = 54 // Same Height for consistency
        
        var numberOfCells: Int!
        
        if collectionView == hobbiesCollectionView
        {
            numberOfCells = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
            let padding = 10
            availableWidth  = collectionView.frame.size.width - CGFloat(padding * (numberOfCells! - 1))
        }
        else
        {
            numberOfCells = 2
            let padding = 10
            availableWidth  = collectionView.frame.size.width - CGFloat(padding * (numberOfCells! - 1))
        }
        let dynamicCellWidth = availableWidth / CGFloat(numberOfCells!)
        let dynamicCellSize = CGSizeMake(dynamicCellWidth, cellHeight)
        return dynamicCellSize
    }
    
    func saveHobbiesToUserDefaults() {
        let hobbyData = NSKeyedArchiver.archivedDataWithRootObject(myHobbies!)
        NSUserDefaults.standardUserDefaults().setValue(hobbyData, forKey: "MyHobbies")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func showError(message: String)
    {
        let alert = UIAlertController(title: kAppTitle, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getHobbies() {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("MyHobbies") as? NSData
        {
            let savedHobbies = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Array<Hobby>
            
            myHobbies = savedHobbies
        }
    }
    
}
