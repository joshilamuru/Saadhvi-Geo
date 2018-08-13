//
//  Constants.swift
//  sampleForGeo
//
//  Created by saadhvi on 6/16/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit

struct Constants {
    static let APP_NAME = "sampleForGeo"
    struct Routes {
        static let Api = "/api/mobile"
    }
    struct Domains {
        static let Dev = "http://"
        static let UAT = "http://"
        static let Stag = "http://49.207.180.189:8082/taskease/"
        static let Production = "http://enterprise.thetaskease.com/taskease/"

    }
    
        static let authUserMethod = "authenticationUser.htm"
        static let forgotPasswordMethod = "forgetUserPswd.htm"
        static let locationUpdateFromDeviceToServer = "mobileLocationUpdateToServer.htm"
        static let requestPOI = "requestAT.htm"
        static let syncAcctTypes = "WSCustomReadSyncAT.do"
        static let syncTaskTypes = "WSCustomReadSync.do"
        static let createPOI = "WSCreateAccount.do"
}
