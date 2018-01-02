//
//  IITMWKWebView.swift
//  InstrumentITMobileIOSTracing
//
//  Created by NovaTec on 09.10.17.
//  Copyright © 2017 NovaTec. All rights reserved.
//

import UIKit

private let swizzlingLoadRequestMethod: (UIWebView.Type) -> () = { webview in
    
    let originalSelector = #selector(webview.loadRequest(_:))
    let swizzledSelector = #selector(webview.iitmLoadRequest(_:))
    
    let originalMethod = class_getInstanceMethod(webview, originalSelector)
    let swizzledMethod = class_getInstanceMethod(webview, swizzledSelector)
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
}

private let swizzlingLoadHTMLMethod: (UIWebView.Type) -> () = { webview in
    
    let originalSelector = #selector(webview.loadHTMLString(_:baseURL:))
    let swizzledSelector = #selector(webview.iitmLoadHTMLString(_:baseURL:))
    
    let originalMethod = class_getInstanceMethod(webview, originalSelector)
    let swizzledMethod = class_getInstanceMethod(webview, swizzledSelector)
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
}

private let swizzlingReloadMethod: (UIWebView.Type) -> () = { webview in
    
    let originalSelector = #selector(webview.reload)
    let swizzledSelector = #selector(webview.iitmReload)
    
    let originalMethod = class_getInstanceMethod(webview, originalSelector)
    let swizzledMethod = class_getInstanceMethod(webview, swizzledSelector)
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
}

private let swizzlingStopLoadingMethod: (UIWebView.Type) -> () = { webview in
    
    let originalSelector = #selector(webview.stopLoading)
    let swizzledSelector = #selector(webview.iitmStopLoading)
    
    let originalMethod = class_getInstanceMethod(webview, originalSelector)
    let swizzledMethod = class_getInstanceMethod(webview, swizzledSelector)
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
}

private let swizzlingGoForwardMethod: (UIWebView.Type) -> () = { webview in
    
    let originalSelector = #selector(webview.goForward)
    let swizzledSelector = #selector(webview.iitmGoForward)
    
    let originalMethod = class_getInstanceMethod(webview, originalSelector)
    let swizzledMethod = class_getInstanceMethod(webview, swizzledSelector)
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
}

private let swizzlingGoBackMethod: (UIWebView.Type) -> () = { webview in
    
    let originalSelector = #selector(webview.goBack)
    let swizzledSelector = #selector(webview.iitmGoBack)
    
    let originalMethod = class_getInstanceMethod(webview, originalSelector)
    let swizzledMethod = class_getInstanceMethod(webview, swizzledSelector)
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
}


extension UIWebView {
    
    open override class func initialize() {
        // make sure this isn't a subclass
        guard self === URLSession.self else { return }
        swizzlingLoadRequestMethod(self)
        swizzlingLoadHTMLMethod(self)
        swizzlingReloadMethod(self)
        swizzlingStopLoadingMethod(self)
        swizzlingGoForwardMethod(self)
        swizzlingGoBackMethod(self)
    }
    
    func iitmLoadRequest(_ request: URLRequest) {
        let invocation = IITMAgent.getInstance().trackInvocation()
        iitmLoadRequest(request)
        IITMAgent.getInstance().closeInvocation(invocation: invocation!)
    }
    
    func iitmLoadHTMLString(_ string: String, baseURL: URL?) {
        let invocation = IITMAgent.getInstance().trackInvocation()
        iitmLoadHTMLString(string, baseURL: baseURL)
        IITMAgent.getInstance().closeInvocation(invocation: invocation!)
    }
    
    func iitmReload() {
        let invocation = IITMAgent.getInstance().trackInvocation()
        iitmReload()
        IITMAgent.getInstance().closeInvocation(invocation: invocation!)
    }
    
    func iitmStopLoading() {
        let invocation = IITMAgent.getInstance().trackInvocation()
        iitmStopLoading()
        IITMAgent.getInstance().closeInvocation(invocation: invocation!)
    }
    
    func iitmGoForward() {
        let invocation = IITMAgent.getInstance().trackInvocation()
        iitmGoForward()
        IITMAgent.getInstance().closeInvocation(invocation: invocation!)
    }
    
    func iitmGoBack() {
        let invocation = IITMAgent.getInstance().trackInvocation()
        iitmGoBack()
        IITMAgent.getInstance().closeInvocation(invocation: invocation!)
    }
    
}

