//
//  TLDRResponse.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

struct TLDRResponse {
    let data: NSData!
    let response: NSURLResponse!
    var error: NSError?
    
    var responseJSON: AnyObject? {
        if let data = data {
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                    return jsonResult
                }
            }  catch let error as NSError {
                // TODO: error handling
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
    
    var responseString: String? {
        if let data = data, string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return String(string)
        } else {
            return nil
        }
    }
}