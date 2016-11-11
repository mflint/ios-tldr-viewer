//
//  TLDRRequest.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

class TLDRRequest: NSObject, URLSessionTaskDelegate {
    typealias NetworkingCompletion = (TLDRResponse) -> Void
    
    class func requestWithURL(urlString: String, completion:@escaping NetworkingCompletion) {
        let url = URL(string: urlString)
        let request = URLRequest(url: url! as URL)
        
        let session = URLSession(configuration: URLSessionConfiguration.TLDRSessionConfiguration())
        
        let task = session.dataTask(with: request) {
            data, response, sessionError in
            let wrappedResponse = TLDRResponse(data: data, response: response, error: sessionError)
            completion(wrappedResponse)
        }
        
        task.resume()
    }
}
