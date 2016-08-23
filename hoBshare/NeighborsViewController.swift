//
//  NeighborsViewController.swift
//  hoBshare
//
//  Created by Miguel Melendez on 8/5/16.
//  Copyright © 2016 Miguel Melendez. All rights reserved.
//

import UIKit
import MapKit

class NeighborsViewController: HoBshareViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var users: [User]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
    }
    
    override func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        locationManager.stopUpdatingLocation()
        self.centerMapOnCurrentLocation()
    }
    
    func centerMapOnCurrentLocation() {
        guard currentLocation != nil else
        {
            print("Current location unavailable.")
            return
        }
        
        mapView.setCenterCoordinate(currentLocation!.coordinate, animated: true)
        
        let currentRegion = mapView.regionThatFits(MKCoordinateRegionMake(CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude), MKCoordinateSpanMake(0.5, 0.5)))
        mapView.setRegion(currentRegion, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let users = self.users
        {
                mapView.removeAnnotations(users)
        }
        
        self.fetchUsersWithHobby(myHobbies![indexPath.row])
        
        let thisCell = collectionView.cellForItemAtIndexPath(indexPath) as! HobbyCollectionViewCell
        for cell in collectionView.visibleCells() {
            if cell != thisCell
            {
                cell.backgroundColor = UIColor.darkGrayColor()

            }
            else
            {
                thisCell.backgroundColor = UIColor.redColor()
            }
        }
    }
    
    func fetchUsersWithHobby(hobby: Hobby) {
        guard
        (NSUserDefaults.standardUserDefaults().valueForKey("CurrentUserId") as? String)!.characters.count > 0 else
        {
            let alert = UIAlertController(title: kAppTitle, message: "Please login before selecting a hobby.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
            
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // Make REST call
        
        let requestUser = User()
        
        requestUser.userId = NSUserDefaults.standardUserDefaults().valueForKey("CurrentUserId") as? String
        requestUser.latitude = currentLocation?.coordinate.latitude
        requestUser.longitude = currentLocation?.coordinate.longitude
        
        UserDP().fetchUsersForHobby(requestUser, hobby: hobby) { (returnedListOfUsers) in
            if returnedListOfUsers.status.code == 0
            {
                self.users = returnedListOfUsers.users
                
                // Get rid of the last set of users and remove their annotations from the map
                
                if let users = self.users
                {
                    self.mapView.removeAnnotations(users)
                }
                
                // Create a pin for each user and add it to the map
                
                if let users = self.users {
                    for user in users {
                        self.mapView.addAnnotation(user)
                    }
                    // Zoom to show the nearest users in relation to the current user's position
                    if self.currentLocation != nil
                    {
                        let me = User(userName: "Me", hobbies: self.myHobbies!, lat: self.currentLocation!.coordinate.latitude, lon: self.currentLocation!.coordinate.longitude)
                        self.mapView.addAnnotation(me)
                        
                        let neighborsAndMe = users + [me]
                        
                        self.mapView.showAnnotations(neighborsAndMe, animated: true)
                    }
                    else
                    {
                        self.mapView.showAnnotations(users, animated: true)
                    }
                }
            }
            else
            {
                self.showError(returnedListOfUsers.status.statusDescription!)
            }
        }
    }
    
}
