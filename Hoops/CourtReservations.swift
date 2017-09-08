//
//  CourtReservations.swift
//  Hoops
//
//  Created by Omar Droubi on 11/24/16.
//  Copyright © 2016 Omar Droubi. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase


class CourtReservations : UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var menu: UIBarButtonItem!
    
    @IBOutlet var tableView: UITableView!
    var reservations = [Event]()
    
    var eventRef: FIRDatabaseReference!
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    private let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    override func viewDidLoad() {
        // Read DATABASE
        eventRef = FIRDatabase.database().reference()
        eventRef.child("Court Reservations").queryOrderedByKey().observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            let eventTitle = snapshotValue!["Event Title"] as! String
            let location = snapshotValue!["Location"] as! String
            let addedByUser = snapshotValue!["Added by"] as! String
            let duration = snapshotValue!["Duration"] as! String
            let notes = snapshotValue!["Notes"] as! String
            let date = snapshotValue!["Date"] as! String
            
            self.reservations.append(Event(eventTitle: eventTitle, location: location, addedByUser: addedByUser, duration: duration, notes: notes, date: date))
            
            self.tableView.reloadData()
            
        })
        
        menu.target = self.revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
        self.calendar.select(self.formatter.date(from: "2015/10/10")!)
        //        self.calendar.scope = .week
        self.calendar.scopeGesture.isEnabled = true
        //        calendar.allowsMultipleSelection = true
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Simple iPhone 6 Wallpaper 200.jpg")!)
        
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return self.formatter.date(from: "2015/01/01")!
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return self.formatter.date(from: "2016/10/31")!
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let day: Int! = self.gregorian.component(.day, from: date)
        return day % 5 == 0 ? day/5 : 0;
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        NSLog("change page to \(self.formatter.string(from: calendar.currentPage))")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        NSLog("calendar did select date \(self.formatter.string(from: date))")
    }
    
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let day: Int! = self.gregorian.component(.day, from: date)
        return [13,24].contains(day) ? UIImage(named: "icon_cat") : nil
    }
    
    //Table of Events
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("EventCell", owner: self, options: nil)?.first as! EventCell
        
        cell.titleEvent.text = reservations[indexPath.row].eventTitle
        cell.location.text = reservations[indexPath.row].location
        cell.timeAndDuration.text = reservations[indexPath.row].date + "\n" + reservations[indexPath.row].duration + " minutes"
        
        
        return cell
    }
    // to remove keyboard when finished writing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    
    
    
}
