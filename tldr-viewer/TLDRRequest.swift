//
//  TLDRRequest.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

class TLDRRequest: NSObject, NSURLSessionTaskDelegate {
    typealias NetworkingCompletion = TLDRResponse -> Void
    
    class func requestWithURL(urlString: String, completion:NetworkingCompletion) {
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.TLDRSessionConfiguration());
        
        let task = session.dataTaskWithRequest(request) {
            data, response, sessionError in
            let wrappedResponse = TLDRResponse(data: data, response: response, error: sessionError)
            completion(wrappedResponse)
        }
        
        task.resume()
    }
}