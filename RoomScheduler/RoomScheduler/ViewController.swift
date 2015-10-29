//
//  ViewController.swift
//  RoomScheduler
//
//  Created by Mike Henry on 10/29/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {
    
    @IBOutlet weak var beginDatePicker  :UIDatePicker!
    @IBOutlet weak var durationSlider   :UISlider!
    @IBOutlet weak var scheduleButton   :UIButton!
    let eventStore = EKEventStore()

    
    //MARK: - Room Scheduler Methods
    
    @IBAction func newRoomBooking(sender: UIButton) {
        print("Schedule It button pressed")
    }
    
    
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
            requestAccesstoEKType(type) // we added this after we crated the method above
        case .Authorized:
            print("Authorized")
        case .Restricted, .Denied:
            print("Restricted/Denied")
        }
    }
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkEKAuthorizationStatus(.Event)
        checkEKAuthorizationStatus(.Reminder)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

