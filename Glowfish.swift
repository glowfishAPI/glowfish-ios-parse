//
//  Glowfish.swift
//  glowfish-ios-parse
//
//  Created by Patrick Kearney on 3/7/15.
//  Copyright (c) 2015 Glowfish. All rights reserved.
//

import Foundation

let STATIC_GLOWFISH_URL: String = "https://api.glowfi.sh/"
let STATIC_GLOWFISH_VERSION: String = "v1"

public class Glowfish {
    var sid: String! = nil
    var token: String! = nil
    var verbose: Bool = false
    //private(set) var allResults: Bool! = false
    
    class var glower: Glowfish {
        struct Static {
            static let instance: Glowfish = Glowfish()
        }
        return Static.instance
    }
    
    class func debug(debug: Bool = true){
        self.glower.verbose = debug
    }
    
    class func setCredentials(sid: String!, token: String!){
        self.glower.sid = sid
        self.glower.token = token
    }
    
    class func endpoint(endpoint: String? = nil) -> String {
        if endpoint != nil {
            return STATIC_GLOWFISH_URL + STATIC_GLOWFISH_VERSION + "/" + endpoint! + "/"
        }
        
        return STATIC_GLOWFISH_URL + STATIC_GLOWFISH_VERSION + "/"
    }
    
    func log(message: AnyObject!){
        if self.verbose {
            println(message)
        }
    }
    
    func train(data: [String: AnyObject], response: [String: AnyObject], complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        self.glowfishRequest(["data_set": data, "response": response], endpoint: "train") { (objects, error) -> () in
            complete(objects: objects, error: error)
        }
    }
    
    func predict(data: [String: AnyObject], response: [String: AnyObject], complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        self.glowfishRequest(["data_set": data, "response": response], endpoint: "predict") { (objects, error) -> () in
            complete(objects: objects, error: error)
        }
    }
    
    func cluster(data: [String: AnyObject], response: [String: AnyObject], complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        self.glowfishRequest(["data_set": data, "response": response], endpoint: "cluster") { (objects, error) -> () in
            complete(objects: objects, error: error)
        }
    }
    
    func featureSelect(data: [String: AnyObject], response: [String: AnyObject], complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        self.glowfishRequest(["data_set": data, "response": response], endpoint: "feature_select") { (objects, error) -> () in
            complete(objects: objects, error: error)
        }
    }
    
    func glowfishRequest(data: [String: AnyObject], endpoint: String, complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        let startDate: NSDate = NSDate()
        self.log("Started request to endpoint \(endpoint)")
        
        let URL = NSURL(string: Glowfish.endpoint(endpoint: endpoint))!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        
        let authStr = self.sid + ":" + self.token
        var authData = authStr.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)!
        let authValue = "Basic " + authData.base64EncodedStringWithOptions(nil)
        mutableURLRequest.setValue(authValue, forHTTPHeaderField: "Authorization")
        
        let parameters = data
        var JSONSerializationError: NSError? = nil
        mutableURLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &JSONSerializationError)
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request(mutableURLRequest)/*.authenticate(user: self.sid, password: self.token)*/.responseJSON(options: NSJSONReadingOptions.MutableContainers|NSJSONReadingOptions.MutableLeaves|NSJSONReadingOptions.AllowFragments) { (request, response, responseData, responseError) -> Void in
            let endDate: NSDate = NSDate()
            let dateComponents: NSDateComponents = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.components(NSCalendarUnit.CalendarUnitSecond, fromDate: startDate, toDate: endDate, options: NSCalendarOptions(0))
            
            if responseError == nil {
                var currentCode: Int = 400
                var currentStatus: [String: AnyObject]? = nil
                
                if let data: AnyObject = responseData {
                    if let formattedData = data as? [String: AnyObject] {
                        if let internalStatus: AnyObject = formattedData["status"] {
                            if let status = internalStatus as? [String: AnyObject] {
                                currentStatus = status
                                
                                if let code: AnyObject = status["code"] {
                                    if let formattedCode = code as? String {
                                        var cc = Int((formattedCode as NSString).floatValue)
                                        if cc != 200 {
                                            if let codeMessage: AnyObject = status["codeMessage"] {
                                                if let message = codeMessage as? String {
                                                    self.log("Resolved endpoint \(endpoint) in \(dateComponents.second) seconds with error \(message)")
                                                    return complete(objects: nil, error: NSError(domain: message, code: cc, userInfo: ["status": status]))
                                                }
                                            }
                                            
                                            currentCode = cc
                                            
                                        } else {
                                            self.log("Resolved endpoint \(endpoint) in \(dateComponents.second) seconds with \(formattedData.count) object keys")
                                            return complete(objects: responseData as? [String: AnyObject], error: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                self.log("Resolved endpoint \(endpoint) in \(dateComponents.second) seconds with error")
                return complete(objects: nil, error: NSError(domain: "An unknown error occurred", code: currentCode, userInfo: currentStatus))
            } else {
                self.log("Resolved endpoint \(endpoint) in \(dateComponents.second) with error \(responseError)")
                return complete(objects: nil, error: responseError)
            }
        }
    }
}