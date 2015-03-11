//
//  Glowfish+Parse.swift
//  glowfish-ios-parse
//
//  Created by Patrick Kearney on 3/7/15.
//  Copyright (c) 2015 Glowfish. All rights reserved.
//

import Foundation
import Parse

class PFGlowfish: Glowfish {
    private(set) var allResults: Bool! = false
    
    override class var glower: PFGlowfish {
        struct Static {
            static let instance: PFGlowfish = PFGlowfish()
        }
        return Static.instance
    }
    
    class func findAllResultsWhenUsingParse(findAllResults: Bool! = true){
        self.glower.allResults = findAllResults
    }
    
    class func train(parseDataQuery: PFQuery!, parseDataFields: [String]!, parseResponseQuery: PFQuery!, parseResponseField: String!, complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        self.glower.query_parse_with_data_and_response(parseDataQuery, parseDataFields: parseDataFields, parseResponseQuery: parseResponseQuery, parseResponseField: parseResponseField, complete: { (data_set, response, error) -> () in
            self.glower.train(data_set!, response: response!, complete)
        })
    }
    
    class func predict(parseDataQuery: PFQuery!, parseDataFields: [String]!, parseResponseQuery: PFQuery?, parseResponseField: String?, complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        self.glower.query_parse_with_data_and_response(parseDataQuery, parseDataFields: parseDataFields, parseResponseQuery: parseResponseQuery, parseResponseField: parseResponseField, complete: { (data_set, response, error) -> () in
            self.glower.predict(data_set!, response: response!, complete)
        })
    }
    
    class func cluster(parseDataQuery: PFQuery!, parseDataFields: [String]!, parseResponseQuery: PFQuery!, parseResponseField: String!, complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        self.glower.query_parse_with_data_and_response(parseDataQuery, parseDataFields: parseDataFields, parseResponseQuery: parseResponseQuery, parseResponseField: parseResponseField, complete: { (data_set, response, error) -> () in
            self.glower.cluster(data_set!, response: response!, complete)
        })
    }
    
    class func featureSelect(parseDataQuery: PFQuery!, parseDataFields: [String]!, parseResponseQuery: PFQuery!, parseResponseField: String!, complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        self.glower.query_parse_with_data_and_response(parseDataQuery, parseDataFields: parseDataFields, parseResponseQuery: parseResponseQuery, parseResponseField: parseResponseField, complete: { (data_set, response, error) -> () in
            self.glower.featureSelect(data_set!, response: response!, complete)
        })
    }
    
    private func query_parse_with_only_data(parseDataQuery: PFQuery!, parseDataFields: [String]!, complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        let startDate: NSDate = NSDate()
        self.log("Started querying parse collection for data_set in \(parseDataQuery.parseClassName)")
        
        var parseData: [String: AnyObject]?
        self.assess_parse_query(parseDataQuery, fields: parseDataFields) { (objects, error) -> () in
            let endDate: NSDate = NSDate()
            let dateComponents: NSDateComponents = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.components(NSCalendarUnit.CalendarUnitSecond, fromDate: startDate, toDate: endDate, options: NSCalendarOptions(0))
            
            if error == nil {
                self.log("Finished querying parse in \(dateComponents.second) seconds with \(parseData?.count) objects")
            } else {
                self.log("Finished querying parse in \(dateComponents.second) seconds with error \(error)")
            }
            
            complete(objects: objects, error: error)
        }
    }
    
    private func query_parse_with_data_and_response(parseDataQuery: PFQuery!, parseDataFields: [String]!, parseResponseQuery: PFQuery!, parseResponseField: String!, complete: (dataSet: [String: AnyObject]?, response: [String: AnyObject]?, error: NSError?) -> ()){
        let startDate: NSDate = NSDate()
        self.log("Started querying parse collection for data_set in \(parseDataQuery.parseClassName) and resposnse in \(parseResponseQuery.parseClassName)")
        
        var parseData: [String: AnyObject]?
        var parseResponse: [String: AnyObject]?
        
        self.assess_parse_query(parseDataQuery, fields: parseDataFields) { (objects, error) -> () in
            let endDate: NSDate = NSDate()
            let dateComponents: NSDateComponents = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.components(NSCalendarUnit.CalendarUnitSecond, fromDate: startDate, toDate: endDate, options: NSCalendarOptions(0))
            
            parseData = objects
            if parseResponse != nil {
                if error == nil {
                    self.log("Finished querying parse in \(dateComponents.second) seconds with \(parseData?.count) objects")
                    
                    complete(dataSet: parseData, response: parseResponse, error: nil)
                } else {
                    self.log("Finished querying parse in \(dateComponents.second) seconds with error \(error)")
                    
                    complete(dataSet: nil, response: nil, error: error)
                }
            }
        }
        
        self.assess_parse_query(parseResponseQuery, fields: [parseResponseField]) { (objects, error) -> () in
            let endDate: NSDate = NSDate()
            let dateComponents: NSDateComponents = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.components(NSCalendarUnit.CalendarUnitSecond, fromDate: startDate, toDate: endDate, options: NSCalendarOptions(0))
            
            parseResponse = objects
            if parseData != nil {
                if error == nil {
                    self.log("Finished querying parse in \(dateComponents.second) seconds with \(parseData?.count) objects")
                    
                    complete(dataSet: parseData, response: parseResponse, error: nil)
                } else {
                    self.log("Finished querying parse in \(dateComponents.second) seconds with error \(error)")
                    
                    complete(dataSet: nil, response: nil, error: error)
                }
            }
        }
    }
    
    func assess_parse_query(query: PFQuery!, fields: [String]!, complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        if self.allResults == true {
            self.count_query_parse(query, complete: { (cnt, error) -> () in
                if error == nil {
                    self.loop_parse_query(query, fields: fields, currentObjs: [], currentCnt: 0, totalCnt: cnt, complete: { (objects, error) -> () in
                        if error == nil {
                            self.format_parse_collection(objects as [[String: AnyObject]], complete: { (objects, error) -> () in
                                complete(objects: objects, error: error)
                            })
                        } else {
                            complete(objects: nil, error: error)
                        }
                    })
                } else {
                    complete(objects: nil, error: error)
                }
            })
        } else {
            self.query_parse(query, fields: fields, complete: { (objects, error) -> () in
                if error == nil {
                    self.format_parse_collection(objects as [[String: AnyObject]], complete: { (objects, error) -> () in
                        complete(objects: objects, error: error)
                    })
                } else {
                    complete(objects: nil, error: error)
                }
            }) // no need to do any counting
        }
    }
    
    func format_parse_collection(collection: [[String: AnyObject]], complete: (objects: [String: AnyObject]?, error: NSError?) -> ()){
        var formattedCollection = [String: AnyObject]()
        var collectionKeys = collection.first?.keys.array
        
        for key in collectionKeys! {
            var arr: [AnyObject] = [AnyObject]()
            formattedCollection[key] = arr
        }
        
        for object in collection {
            for (key, val) in object {
                var feature = formattedCollection[key] as [AnyObject]
                feature.append(val)
                formattedCollection[key] = feature
            }
        }
        
        complete(objects: formattedCollection, error: nil)
    }
    
    func loop_parse_query(query: PFQuery!, fields: [String]!, var currentObjs: [AnyObject] = [], var currentCnt: Int = 0, totalCnt: Int, complete: (objects: [AnyObject]?, error: NSError?) -> ()){
        query.skip = currentCnt
        
        self.query_parse(query, fields: fields, complete: { (objects, error) -> () in
            if error == nil {
                currentObjs += objects!
                currentCnt += objects!.count
                
                if currentCnt < totalCnt {
                    self.loop_parse_query(query, fields: fields, currentObjs: currentObjs, currentCnt: currentCnt, totalCnt: totalCnt, complete: complete)
                } else {
                    complete(objects: currentObjs, error: nil)
                }
            }
        })
    }
    
    func count_query_parse(query: PFQuery!, complete: (cnt: Int, error: NSError?) -> ()){
        query.countObjectsInBackgroundWithBlock { (cnt, err) -> Void in
            complete(cnt: Int(cnt), error: err)
        }
    }
    
    func query_parse(query: PFQuery!, fields: [String]!, complete: (objects: [AnyObject]?, error: NSError?) -> ()){
        query.findObjectsInBackgroundWithBlock { (objects, err) -> Void in
            if err != nil {
                complete(objects: nil, error: err)
            } else {
                var formattedObjs: [AnyObject] = []
                for object: PFObject in (objects as [PFObject]) {
                    var formattedObject = [String: AnyObject]()
                    for field: String in fields {
                        formattedObject[field] = object.valueForKey(field)
                    }
                    formattedObjs.append(formattedObject)
                }
                
                complete(objects: formattedObjs, error: nil)
            }
        }
    }
}
