//
//  Models.swift
//  hoBshare
//
//  Created by Miguel Melendez on 8/5/16.
//  Copyright © 2016 Miguel Melendez. All rights reserved.
//

import Foundation
import MapKit

extension Array
{
    var allValuesAreHobbies: Bool {
        var returnValue = true
        for value in self
        {
            if value is Hobby == false
            {
                returnValue = false
            }
        }
        return returnValue
    }
    
    func toString() -> String {
        var returnString = ""
        if (allValuesAreHobbies)
        {
            for i in 0...self.count-1
            {
                let value = self[i] as! Hobby
                if i == 0
                {
                    returnString += value.hobbyName!
                }
                else
                {
                    returnString += ", " + value.hobbyName!
                }
            }
        }
        return returnString
    }
    
}

class User: SFLBaseModel, JSONSerializable, MKAnnotation {
    var userId : String?
    var userName : String?
    var latitude : Double?
    var longitude : Double?
    var hobbies = [Hobby]()
    var searchHobby : Hobby? // Used in call to fetch users who share hobby
    
    override init() {
        super.init()
        self.delegate = self
    }
    
    init(userName:String) {
        super.init()
        self.delegate = self
        self.userName = userName
    }
    
    convenience init(userName: String, hobbies: [Hobby], lat: Double, lon: Double) {
        self.init(userName: userName)
        self.latitude = lat
        self.longitude = lon
        self.hobbies = hobbies
    }
    
    override func getJSONDictionary() -> NSDictionary {
        let dict = super.getJSONDictionary()
        
        if self.userId != nil {
            dict.setValue(self.userId, forKey: "UserId")
        }
        
        if self.userName != nil {
            dict.setValue(self.userName, forKey: "Username")
        }
        
        if self.latitude != nil {
            dict.setValue(self.latitude, forKey: "Latitude")
        }
        
        if self.longitude != nil {
            dict.setValue(self.longitude, forKey: "Longitude")
        }
        
        var jsonSafeHobbiesArray = [String]()
        
        for hobby in self.hobbies {
            jsonSafeHobbiesArray.append(hobby.hobbyName!)
        }
        
        dict.setValue(jsonSafeHobbiesArray, forKey: "Hobbies")
        
        if self.searchHobby != nil {
            dict.setValue(self.searchHobby?.hobbyName, forKey: "HobbySearch")
        }
        
        return dict
    }
    
    override func readFromJSONDictionary(dict: NSDictionary) {
        super.readFromJSONDictionary(dict)
        self.userId = dict["UserId"] as? String
        self.userName = dict["Username"] as? String
        self.latitude = dict["Latitude"] as? Double
        self.longitude = dict["Longitude"] as? Double
        
        let returnedHobbies = dict["Hobbies"] as? NSArray
        
        if let hobbies = returnedHobbies {
            self.hobbies = Hobby.deserializeHobbies(hobbies)
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
        }
    }
    
    var title: String? {
        get {
            return self.userName
        }
    }
    
    var subtitle: String? {
        get {
            var hobbiesAsString = ""
            hobbiesAsString = hobbies.toString()
            return hobbiesAsString
        }
    }
}

class ListOfUsers: SFLBaseModel, JSONSerializable {
    var users = [User]()
    
    override init() {
        super.init()
        self.delegate = self
    }
    
    override func readFromJSONDictionary(dict: NSDictionary) {
        super.readFromJSONDictionary(dict)
        
        if let returnedUsers = dict["ListOfUsers"] as? NSArray
        {
            for dict in returnedUsers
            {
                let user = User()
                user.readFromJSONDictionary(dict as! NSDictionary)
                self.users.append(user)
            }
        }
    }
    
    override func getJSONDictionary() -> NSDictionary {
        let dict = super.getJSONDictionary()
        return dict
    }
    
    override func getJSONDictionaryString() -> NSString {
        return super.getJSONDictionaryString()
    }
    
    
}

class Hobby: SFLBaseModel, NSCoding {
    var hobbyName : String?
    
    init(hobbyName: String) {
        super.init()
        self.hobbyName = hobbyName
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.hobbyName = aDecoder.decodeObjectForKey("HobbyName") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.hobbyName, forKey: "HobbyName")
    }
    
    class func deserializeHobbies(hobbies : NSArray) -> Array<Hobby> {
        var returnArray = Array<Hobby>()
        for hobby in hobbies {
            if let hobbyName = hobby as? String {
                returnArray.append(Hobby(hobbyName: hobbyName))
            }
        }
        return returnArray
    }
}