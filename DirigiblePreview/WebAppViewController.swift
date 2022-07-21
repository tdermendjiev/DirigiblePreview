//
//  WebAppViewController.swift
//  DirigiblePreview
//
//  Created by Dermendzhiev, Teodor (external - Project) on 19.07.22.
//

import UIKit

import UIKit
import WebKit

class WebAppViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    

    @IBOutlet weak var webview: WKWebView!
    var ns: NativeScript!
    var appUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(messagePosted), name: Notification.Name(rawValue: "ns-message-posted"), object: nil)
        
        webview.navigationDelegate = self
        
        webview.configuration.userContentController.add(self, name: "executor")
        webview.configuration.userContentController.add(self, name: "postMessageListener")
        
        let config = Config()
        config.isDebug = true
        config.logToSystemConsole = true
        config.baseDir = "."
        config.applicationPath = "."
        
        ns = NativeScript(config: config)
        ns.run("console.log('Hello from NativeScript')", runLoop: false)
        
        if let targetURL = URL(string: appUrl) {
            let request = URLRequest(url: targetURL)
            
            WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{
                self.webview.load(request)
            })
            
        }
                
    }
    
    @objc func messagePosted(_ notification: Notification) {
        if let obj = notification.object as? String {
            let js = "onNativeMessage(\(obj))"
            webview.evaluateJavaScript(js, completionHandler: nil)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "executor") {
            ns.run(message.body as! String, runLoop: false)
        }
        
        if (message.name == "postMessageListener") {
            ns.run("onmessage(\(message.body)", runLoop: false)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webview.evaluateJavaScript(getWorkerScript()) { res, error in
            if let err = error {
                print(err)
            }
        }
    }
    
    func getWorkerScript() -> String {
        return "class NSWorker {\r\n\r\n    constructor(script) {\r\n        this.script = script;\r\n        this.onerror = null;\r\n        this.onmessage = null;\r\n        this.onmessageerror = null;\r\n        this.execute();\r\n    }\r\n\r\n    postMessage(msg) {\r\n        if (window && window.webkit) {\r\n            window.webkit.messageHandlers.postMessageListener.postMessage(msg);\r\n        } else {\r\n            console.log(\"No webkit\")\r\n        }\r\n    }\r\n\r\n    execute() {\r\n        if (window && window.webkit) {\r\n            window.webkit.messageHandlers.executor.postMessage(this.script);\r\n        } else {\r\n            console.log(\"No webkit\")\r\n        }\r\n    }\r\n\r\n    terminate() {\r\n        if (window && window.webkit) {\r\n            window.webkit.messageHandlers.terminator.postMessage(this.script);\r\n        } else {\r\n            console.log(\"No webkit\")\r\n        }\r\n    }\r\n\r\n}\r\n\r\nlet onNativeMessage = function(msg) {\r\n    console.log(\"Message from native: \" + msg)\r\n}"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


}

