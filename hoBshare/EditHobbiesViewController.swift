//
//  EditHobbiesViewController.swift
//  hoBshare
//
//  Created by Miguel Melendez on 8/5/16.
//  Copyright © 2016 Miguel Melendez. All rights reserved.
//

import UIKit

class EditHobbiesViewController: HoBshareViewController {

    @IBOutlet weak var availableHobbiesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.availableHobbiesCollectionView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(true)
        updateAvailableHobbies()
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        updateAvailableHobbies()
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HobbyCategoryHeader", forIndexPath: indexPath)
        (reusableView as! HobbiesCollectionViewHeader).categoryLabel.text = Array(availableHobbies.keys)[indexPath.section]
        
        return reusableView
    }
    
    func saveHobbies() {
        
        let requestUser = User()
        requestUser.userId = NSUserDefaults.standardUserDefaults().valueForKey("CurrentUserId") as? String
        
        if let myHobbies = self.myHobbies
        {
            requestUser.hobbies = myHobbies
        }
        
        HobbyDP().saveHobbiesForUser(requestUser) { (returnedUser) -> () in
            if returnedUser.status.code == 0
            {
                self.saveHobbiesToUserDefaults()
                self.hobbiesCollectionView.reloadData()
            }
            else
            {
                self.showError(returnedUser.status.statusDescription!)
            }
            self.updateAvailableHobbies()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == availableHobbiesCollectionView
        {
            let key = Array(availableHobbies.keys)[indexPath.section]
            let hobbies = availableHobbies[key]
            let hobby =  hobbies![indexPath.item]
            
            if myHobbies?.contains({$0.hobbyName == hobby.hobbyName}) == false
            {
                if myHobbies!.count < kMaxHobbies
                {
                    myHobbies! += [hobby]
                    self.saveHobbies()
                }
                else
                {
                    // Logic for asking to swap hobby
                    let alert = UIAlertController(title: kAppTitle, message: "Would you like to swap for another hobby?", preferredStyle: .ActionSheet)
                    
                    for curHobby in myHobbies! {
                        let swapAction = UIAlertAction(title: curHobby.hobbyName, style: .Default, handler: { (action) in
                            // Swap the two hobbies
                            let index = self.myHobbies!.indexOf(curHobby)!
                            self.myHobbies!.removeAtIndex(index)
                            self.myHobbies!.insert(hobby, atIndex: index)
                            self.saveHobbies()
                            alert.dismissViewControllerAnimated(true, completion: nil)
                        })
                        alert.addAction(swapAction)
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    })

                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
            
        }
        else
        {
            let alert = UIAlertController(title: kAppTitle, message: "Would you like to remove this hobby?", preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {(action) in
                self.myHobbies!.removeAtIndex(indexPath.item)
                self.saveHobbies()
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: {(action) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
            
            alert.addAction(deleteAction)
            
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }

    }
    
    func updateAvailableHobbies() {
        for cell in self.availableHobbiesCollectionView!.visibleCells() as! [HobbyCollectionViewCell] {
            cell.backgroundColor = UIColor.darkGrayColor()
            for hobby in myHobbies! {
                if hobby.hobbyName == cell.hobbyLabel.text {
                    cell.backgroundColor = UIColor.redColor()
                }
            }
        }
    }
    
    

}