//
//  URLSessionInvocationInjection.swift
//  AutomaticInvocationTracker
//
//  Created by Matteo Sassano on 19.05.17.
//  Copyright © 2017 Matteo Sassano. All rights reserved.
//

import Foundation


private let swizzlingDataTask: (URLSession.Type) -> () = { session in
    
    let originalSelector = #selector((URLSession.dataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
    let swizzledSelector = #selector(session.iitmDataTask(request:completionHandler:))
    
    let originalMethod = class_getInstanceMethod(session, originalSelector)
    let swizzledMethod = class_getInstanceMethod(session, swizzledSelector)
    
    method_exchangeImplementations(originalMethod, swizzledMethod);

}


extension URLSession {
    
    open override class func initialize() {
        // make sure this isn't a subclass
        guard self === URLSession.self else { return }
        swizzlingDataTask(self)
    }
    
    func iitmDataTask(request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionDataTask {
        
        var req: NSMutableURLRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        // Ignore instrumentation point in the case of requesting the monitoring server
        var remotecall: IITMRemoteCall? = nil
        if req.url?.absoluteString != IITMAgentConstants.HOST {
            remotecall = IITMAgent.getInstance().trackRemoteCall(url: (req.url?.absoluteString)!)
        }
        if remotecall != nil {
            IITMAgent.getInstance().injectHeaderAttributes(remotecall: remotecall!, request: &req)
        }
        let dataTask = iitmDataTask(request: req as URLRequest, completionHandler: {data, response, error -> Void in
            
            // Ignore instrumentation point in the case of requesting the monitoring server
            
            if remotecall != nil || req.url?.absoluteString != IITMAgentConstants.HOST {
                IITMAgent.getInstance().closeRemoteCall(remotecall: remotecall!, response: response, error: error)
            }

            if completionHandler != nil {
                if req.url?.absoluteString != IITMAgentConstants.HOST {
                    // invocation = IITMAgent.getInstance().trackInvocation()
                    // FOLLOWS FROM !!!
                }
                
                completionHandler!(data, response, error)
                
                if req.url?.absoluteString != IITMAgentConstants.HOST {
                    //IITMAgent.getInstance().closeInvocation(invocation: invocation!)
                }
            }
        })
        return dataTask
    }
    
}











