//
//  ViewController.swift
//  RoomScheduler
//
//  Created by Mike Henry on 10/29/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timeBeginDatePicker  :UIDatePicker!
    @IBOutlet weak var timeDurationSlider   :UISlider!
    @IBOutlet weak var scheduleButton       :UIButton!
    @IBOutlet weak var scheduleTableView    :UITableView!
    var scheduleArray = []
    let eventStore = EKEventStore()

    
    //MARK: - Room Scheduler Methods
    
    @IBAction func newRoomBooking(sender: UIButton) {
        print("Schedule It button pressed")
        let roomEvent = EKEvent(eventStore: eventStore)
        roomEvent.calendar = eventStore.defaultCalendarForNewEvents
        roomEvent.title = "Reserved Event"
        roomEvent.startDate = timeBeginDatePicker.date
        roomEvent.endDate = NSDate().dateByAddingTimeInterval(Double(timeDurationSlider.value))
        do {
            try eventStore.saveEvent(roomEvent, span: .ThisEvent, commit: true)
        } catch {
            print("Error")
        }
        scheduleTableView.reloadData()
    }
    
    @IBAction func timeDurationSliderValue(sender: UISlider) {
        print(timeDurationSlider.value)
//        let addTime = timeDurationSlider.value
//        let endTime = NSNumberFormatter(
    }
    
    func retrieveRoomBookings() {
        let calendars = eventStore.calendarsForEntityType(.Event)
        let startDate = NSDate() // time starting now
        let endDate = NSDate(timeIntervalSinceNow: 604800) // 7 days in advance
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: calendars)
        let events = eventStore.eventsMatchingPredicate(predicate)
        if events.count > 0 {
            for event in events {
                print(event.title)
            }
            scheduleArray = events
            print(scheduleArray)
        }
    }
    
    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomTableViewCell
        let booking = scheduleArray[indexPath.row]
        cell.eventTitleLabel.text = booking.title
        
        let startDateFormatter = NSDateFormatter()
        startDateFormatter.dateFormat = "hh:mm a"
        cell.eventStartLabel.text = startDateFormatter.stringFromDate(booking.startDate)
        
        let endDateFormatter = NSDateFormatter()
        endDateFormatter.dateFormat = "hh:mm a"
        cell.eventEndLabel.text = endDateFormatter.stringFromDate(booking.endDate)
        
        
        
        return cell
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
        
        retrieveRoomBookings()
        
        
        timeBeginDatePicker.minimumDate = NSDate() // TODO: Come back to this
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

