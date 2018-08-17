//
//  NetworkManager.swift
//  sampleForGeo
//
//  Created by saadhvi on 8/11/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

//
//  NetworkManager.swift
//  sampleForGeo
//
//  Created by saadhvi on 8/11/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import Reachability

class NetworkManager: NSObject {
    
    let reachability = Reachability()!
    
    // Create a singleton instance
    static let sharedInstance: NetworkManager = { return NetworkManager() }()
    
    override init() {
        super.init()
       
    }
    
    @objc func reachabilityChanged(_ notification: Notification) {
        let reachability = notification.object as! Reachability
        
        switch reachability.connection {
        case .wifi, .cellular:

            print("Reachable via WiFi/cellular-Syncing data..")

            SyncAcctToServer.SharedSyncInstance.syncData()
      
        case .none:
            print("Network not reachable")
            let alert = UIAlertController(title: "Internet Connection Lost", message: "Please check your internet connection", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(cancelButton)
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    
 
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: .reachabilityChanged,
                                                  object: reachability)
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection != .none {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .none {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .cellular {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
}
