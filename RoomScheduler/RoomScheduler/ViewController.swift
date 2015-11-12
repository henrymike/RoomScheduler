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
    
    //MARK: - Properties
    
    @IBOutlet weak var timeBeginDatePicker  :UIDatePicker!
    @IBOutlet weak var timeDurationSlider   :UISlider!
    @IBOutlet weak var timeDurationLabel    :UILabel!
    @IBOutlet weak var scheduleButton       :UIButton!
    @IBOutlet weak var scheduleTableView    :UITableView!
    @IBOutlet weak var introTextLabel       :UILabel!
    var scheduleArray = []
    var permissionsManager = PermissionsManager.sharedInstance
    let eventStore = EKEventStore()

    
    //MARK: - Intro Display Methods
    
    func setIntroText (sender: UILabel) {
        let introMuteString = NSMutableAttributedString()
        let font1 = UIFont(name: "HelveticaNeue", size: 16.0)
        let attrib1 = [NSFontAttributeName: font1!]
        let titleAttribString = NSAttributedString(string: "Book a Meeting Room\n", attributes: attrib1)
        
        let font2 = UIFont(name: "HelveticaNeue-LightItalic", size: 12.0)
        let subtitleAttribString = NSAttributedString(string: "choose a date and time to get started", attributes: [NSFontAttributeName : font2!, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
        
        introMuteString.appendAttributedString(titleAttribString)
        introMuteString.appendAttributedString(subtitleAttribString)
        
        introTextLabel.attributedText = introMuteString
    }
    
    
    //MARK: - Alert Methods
    
    func addEventErrorAlert() {
        let addEventErrorAlert = UIAlertController(title: "Could Not Reserve Room", message: "Another meeting already exists", preferredStyle: .Alert)
        addEventErrorAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(addEventErrorAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Room Scheduler Methods
    
    @IBAction func newRoomBooking(sender: UIButton) {
        print("Schedule It button pressed")
        // check for calendar entity and create if needed
        let calendars = eventStore.calendarsForEntityType(.Event)
        let filteredCalendars = calendars.filter {$0.title == "TIY Meeting Rooms"}
        if filteredCalendars.isEmpty {
            print("No TIY calendar found")
            createNewCalendar()
            createNewEvent()
        } else {
            print("TIY Calendar found")
            createNewEvent()
        }
    }
    
    func createNewEvent() {
        // get calendar UID
        var calendarUID:String = ""
        for cal in eventStore.calendarsForEntityType(.Event) {
            if cal.title == "TIY Meeting Rooms" { calendarUID = cal.calendarIdentifier }
        }
        
        let roomEvent = EKEvent(eventStore: eventStore)
        roomEvent.calendar = eventStore.calendarWithIdentifier(calendarUID)!
        roomEvent.title = "Reserved Event"
        roomEvent.startDate = timeBeginDatePicker.date
        roomEvent.endDate = (timeBeginDatePicker.date).dateByAddingTimeInterval(Double(timeDurationSlider.value))
        
        // search if previous event is existing at same time
        let TIYcalendar = eventStore.calendarWithIdentifier(calendarUID)
        let predicate = eventStore.predicateForEventsWithStartDate(roomEvent.startDate, endDate: roomEvent.endDate, calendars: [TIYcalendar!])
        print("Prev Event Predicate:\(predicate)")
        let events = eventStore.eventsMatchingPredicate(predicate)
        if events.count == 0 {
            do {
                try eventStore.saveEvent(roomEvent, span: .ThisEvent, commit: true)
                print("New Event Saved/new event created")
            } catch {
                print("New Event Error/did not create")
            }
            timeDurationSlider.value = 1600 // reset slider value
            timeDurationLabel.text = "30" // reset label value
            retrieveRoomBookings()
            scheduleTableView.reloadData()
        } else {
            print("Event Count Error/did not save")
            addEventErrorAlert()
        }
    }
    
    func createNewCalendar() {
        let calendar = EKCalendar(forEntityType: EKEntityType.Event, eventStore: eventStore)
        calendar.title = "TIY Meeting Rooms"
        calendar.source = eventStore.defaultCalendarForNewReminders().source
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            print("Created new calendar")
        } catch {
            print("Cannot create new calendar")
        }
        
    }
    
    @IBAction func retrieveRoomBookings() {
        var calendarUID:String = ""
        for cal in eventStore.calendarsForEntityType(.Event) {
            if cal.title == "TIY Meeting Rooms" { calendarUID = cal.calendarIdentifier }
        }
        let roomEvent = EKEvent(eventStore: eventStore)
        roomEvent.calendar = eventStore.calendarWithIdentifier(calendarUID)!
        let TIYcalendar = eventStore.calendarWithIdentifier(calendarUID)
        let startDate = NSDate() // time starting now
        let endDate = NSDate(timeIntervalSinceNow: 604800) // 7 days in advance
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [TIYcalendar!])
        let events = eventStore.eventsMatchingPredicate(predicate)
        if events.count > 0 {
            for event in events {
                print("Retrieved Event: \(event.title)")
            }
            scheduleArray = events
            scheduleTableView.reloadData()
        }
    }
    
    @IBAction func timeDurationSliderValue(sender: UISlider) {
        print(timeDurationSlider.value)
        timeDurationLabel.text = String(Int(timeDurationSlider.value / 60))
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
        startDateFormatter.dateFormat = "h:mm a"
        cell.eventStartLabel.text = startDateFormatter.stringFromDate(booking.startDate)
        
        let endDateFormatter = NSDateFormatter()
        endDateFormatter.dateFormat = "h:mm a"
        cell.eventEndLabel.text = endDateFormatter.stringFromDate(booking.endDate)
        
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let dayIcon = dayFormatter.stringFromDate(booking.startDate)
        let dayDisplay = UIImage(named: "icon_\(dayIcon)")
        cell.dayImage.image = dayDisplay
        
        return cell
    }

    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        permissionsManager.checkEKAuthorizationStatus(.Event)
        permissionsManager.checkEKAuthorizationStatus(.Reminder)
        setIntroText(introTextLabel)
        retrieveRoomBookings()
        timeBeginDatePicker.minimumDate = NSDate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        retrieveRoomBookings()
    }

}
