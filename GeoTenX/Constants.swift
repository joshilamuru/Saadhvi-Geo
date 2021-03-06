//
//  Constants.swift
//  sampleForGeo
//
//  Created by saadhvi on 6/16/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit

struct Constants {
    static let APP_NAME = "GeoTenX"
    struct Routes {
        static let Api = "/api/mobile"
    }
    struct Domains {
        static let Dev = "http://"
        static let UAT = "http://"
        static let Stag = "http://49.207.180.189:8083/taskease/"
        static let Production = "http://enterprise.thetaskease.com/taskease/"

    }
    
        static let authUserMethod = "authenticationUser.htm"
        static let forgotPasswordMethod = "forgetUserPswd.htm"
        static let locationUpdateFromDeviceToServer = "mobileLocationUpdateToServer.htm"
        static let requestPOI = "requestAT.htm"
        static let syncAcctTypes = "WSCustomReadSyncAT.do"
        static let syncTaskTypes = "WSCustomReadSync.do"
        static let createPOI = "WSCreateAccount.do"
        static let createTask = "WSCreateTask.do"
        static let syncTaskInfo = "requestTaskInfo.htm"
        static let unsyncTaskInfo = "TaskSyncWithAccountID.do"
        static let  uploadImage = "WSUploadSignature.do"
}
