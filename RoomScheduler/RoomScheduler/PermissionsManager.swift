//
//  PermissionsManager.swift
//  RoomScheduler
//
//  Created by Mike Henry on 11/11/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import EventKit

class PermissionsManager: NSObject {
    
    //MARK: - Properties
    
    static let sharedInstance = PermissionsManager()
    let eventStore = EKEventStore()

    
    //MARK: - Permission Methods
    
    func requestAccesstoEKType(type: EKEntityType) {
        eventStore.requestAccessToEntityType(type) { (accessGranted, Error) -> Void in
            if accessGranted {
                print("Granted")
            } else {
                print("Not Granted")
            }
        }
    }
    
    func checkEKAuthorizationStatus(type: EKEntityType) {
        let status = EKEventStore.authorizationStatusForEntityType(type)
        switch status {
        case .NotDetermined:
            print("Not Determined")
            requestAccesstoEKType(type)
        case .Authorized:
            print("Authorized")
        case .Restricted, .Denied:
            print("Restricted/Denied")
        }
    }
    
}
