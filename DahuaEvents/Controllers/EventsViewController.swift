//
//  EventsViewController.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-09.
//  Copyright © 2020 mani. All rights reserved.
//

import UIKit

class EventsViewController: UITableViewController, NoContentBackground {
    var videoStreamURL: URL?
    private var events = [Event]()
    let backgroundView = TableBackgroundView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Events"

        backgroundView.frame = view.frame
        backgroundView.message = "Loading"
        backgroundView.startLoadingOperation()
        tableView.backgroundView = backgroundView

        guard let url = videoStreamURL else { return }

        loadEvents(for: url) { [weak self] events in
            guard let weakSelf = self else { return }

            DispatchQueue.main.async {
                if let events = events {
                    weakSelf.events = events
                    weakSelf.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                    weakSelf.backgroundView.stopLoadingOperation()

                    if events.count == 0 {
                        weakSelf.backgroundView.message = "No Events Found"
                    }
                }
            }
        }
    }
}

extension EventsViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if events.count > 0 {
            hideBackgroundView()
        } else {
            showBackgroundView()
        }

        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell",
                                                 for: indexPath)

        if events.count > 0 {
            let event = events[indexPath.row]
            let startTime = event.startTime
            let endTime = event.endTime

            if let startTime = getFormattedDate(from: startTime),
                let endTime = getFormattedDate(from: endTime) {
                cell.textLabel?.text = "\(startTime) - \(endTime)"
                cell.detailTextLabel?.text = "Channel \(event.channel)"
            }
        }

        return cell
    }
}

extension EventsViewController {
    // MARK: Events

    func loadEvents(for url: URL, completion: @escaping ([Event]?) -> Void) {
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let host = urlComponents.host, let username = urlComponents.user,
                let password = urlComponents.password {
                if let queryItem = urlComponents.queryItems?.filter({ $0.name.contains("channel") }).first,
                    let channel = queryItem.value {
                    let dahuaQuery = DahuaQueryService(host: host,
                                                       username: username,
                                                       password: password)
                    let startOfDay = Date().startOfDay
                    let nextDay = startOfDay.nextDay

                    dahuaQuery.getEvents(channel: channel, startTime: startOfDay.dateString(),
                                         endTime: nextDay?.dateString() ?? startOfDay.dateString(),
                                         directory: "/mnt/dvr/sda0", fileTypes: ["dav", "mp4"],
                                         events: ["VideoMotion"], flags: ["Event", "Timing"],
                                         streams: ["Main"]) { (events, _) in
                                            completion(events)
                    }
                }
            }
        }
    }
}

extension EventsViewController {
    // MARK: - Time and Date

    func timeDifference(first: Date, second: Date) -> TimeInterval {
        return second.timeIntervalSince(first)
    }

    func formatDate(date: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        return dateFormatter.date(from: date)
    }

    func doesEventTimeExist(start: String, end: String) -> Bool? {
        let startDate = formatDate(date: start, format: "yyyy-MM-dd HH:mm:ss")
        let endDate = formatDate(date: end, format: "yyyy-MM-dd HH:mm:ss")

        if let startDate = startDate, let endDate = endDate {
            return timeDifference(first: startDate, second: endDate) > 2.0
        }
        return nil
    }

    func getFormattedDate(from string: String) -> String? {
        let date = formatDate(date: string, format: "yyyy-MM-dd HH:mm:ss")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm:ss a"

        guard let theDate = date else { return nil }

        return dateFormatter.string(from: theDate)
    }
}
