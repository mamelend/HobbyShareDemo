
//
//  SFLConnection.swift
//  SFLibrary
//
//  Created by Ralf Brockhaus and Justin-Nicholas Toyama on 3/6/15.
//  Copyright (c) 2015 Smilefish. All rights reserved.
//

import Foundation
import UIKit

class SFLConnection : NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    var sharedSession: NSURLSession! = NSURLSession.sharedSession()
    var responseDATA = NSMutableData()
    var completion : (NSDictionary) -> () = { (obj) -> () in }
    
    func ajax(url: NSString, verb: NSString, requestBody:SFLBaseModel, completionBlock:(NSDictionary) -> ()) {
        
        let jsonRequest = requestBody.getJSONDictionaryString()
        
        let jsonData = NSData(bytes: jsonRequest.UTF8String, length: jsonRequest.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        let requestURL = NSURL(string: url as String)
        
        let request = NSMutableURLRequest(URL: requestURL!)
        
        print(NSString(format: " \n\n\nSFLConnection.ajax:ver:requestbody:completionBlock() URL = %@ \nVERB = %@ \nREQUEST JSON = %@", requestURL!, verb, jsonRequest) as String)
        
        request.HTTPMethod = verb as String
        request.setValue("application/json; charset = utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonData
        
        let task = sharedSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if error != nil
            {
                
                // Pass the error from the connection to the completionBlock
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                let status = NSDictionary(objects: [NSNumber(int: 1), "The connection failed."], forKeys: ["Code", "Description"])
                
                let jsonDict = ["Status" : status] as NSDictionary
                
                dispatch_async(dispatch_get_main_queue())
                {
                    
                    self.completion(jsonDict)
                    
                }
                
            }
            else
            {
                
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                let returnJSONString = NSString(data:data!, encoding:NSUTF8StringEncoding)
                
                print("SFLConnection.connectionDidFinishLoading(): URL: \(request.URL), VERB: \(request.HTTPMethod), responseJSON: \(returnJSONString)")
                
                var jsonObject: AnyObject?
                
                var jsonDict: NSDictionary!
                
                do
                {
                    
                    jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    
                }
                catch _
                {
                    
                    jsonObject = nil
                }
                
                if let theJSONString = jsonObject as? NSString
                {
                    
                    let status: NSDictionary = NSDictionary(objects: [NSNumber(int: 1), theJSONString], forKeys: ["Code", "Description"])
                    
                    jsonDict = ["Status" : [status]] as NSDictionary
                    
                }
                else
                if let theJSONDict = jsonObject as? NSDictionary
                {
                    
                    if theJSONDict["Status"]  != nil
                    {
                        
                        jsonDict = theJSONDict
                        
                    }
                    else
                    {
                        
                        if let message: AnyObject = theJSONDict["Message"]
                        {
                            
                            print("error:" + (message as! String))
                            
                            let status = NSDictionary(objects: [NSNumber(int: 999), message], forKeys: ["Code", "Description"])
                            
                            jsonDict = ["Status" : status] as NSDictionary
                            
                        }
                        else
                        {
                            let status = NSDictionary(objects: [NSNumber(int: 1), "Unable to read the response."], forKeys: ["Code", "Description"])
                            
                            jsonDict = ["Status" : status] as NSDictionary
                        }
                        
                    }
                    
                }
                else
                {
                    
                    let status = NSDictionary(objects: [NSNumber(int: 1), "No data returned from request."], forKeys: ["Code", "Description"])
                    
                    jsonDict = ["Status" : status] as NSDictionary
                        
                }
                
                dispatch_async(dispatch_get_main_queue())
                {
                    
                    self.completion(jsonDict)
                    
                }
                
            }
            
        })
        
        task.resume()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.completion = completionBlock
        
    }
    
    
    
}

