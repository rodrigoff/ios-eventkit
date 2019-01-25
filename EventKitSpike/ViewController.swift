//
//  ViewController.swift
//  EventKitSpike
//
//  Created by Rodrigo F. Fernandes on 25/01/19.
//  Copyright © 2019 Rodrigo F. Fernandes. All rights reserved.
//

import EventKit
import EventKitUI
import UIKit

class ViewController: UIViewController {
    let eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addEventToCalendarTapped(_ sender: Any) {
        self.eventStore.requestAccess(to: .event) { [unowned self] (granted, error) in
            if granted && error == nil {
                let event = self.createEvent(for: self.eventStore)

                let eventViewController = EKEventEditViewController()
                eventViewController.editViewDelegate = self
                eventViewController.event = event
                eventViewController.eventStore = self.eventStore

                self.present(eventViewController, animated: true, completion: nil)
            }
        }
    }

    func createEvent(for store: EKEventStore) -> EKEvent {
        let event = EKEvent(eventStore: store)
        event.title = "Sample event"
        event.location = "1 Infinite Loop; Cupertino, CA 95014"
        event.notes = "Sample notes"

        var endDateComponent = DateComponents()
        endDateComponent.hour = 2

        event.startDate = Date()
        event.endDate = Calendar.current.date(byAdding: endDateComponent, to: Date())
        event.calendar = store.defaultCalendarForNewEvents

        event.addAlarm(EKAlarm(absoluteDate: event.startDate))

        return event
    }
}

extension ViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        guard controller.event != nil else {
            fatalError("event should not be nil")
        }

        switch action {
        case .saved:
            save(controller.event!, from: controller)
        case .canceled:
            print("Event not added to calendar")
        case .deleted:
            print("Event deleted from calendar")
        }

        controller.dismiss(animated: true, completion: nil)
    }

    func save(_ event: EKEvent, from controller: EKEventEditViewController) {
        do {
            try self.eventStore.save(event, span: .thisEvent)
        } catch {
            print("Failure saving event")
        }
    }
}
