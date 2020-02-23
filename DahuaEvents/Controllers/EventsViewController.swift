//
//  EventsViewController.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-09.
//  Copyright © 2020 mani. All rights reserved.
//

import UIKit

class EventsViewController: UITableViewController {
    var videoStreamURL: URL?
    private var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = videoStreamURL else { return }

        loadEvents(for: url) { [weak self] events in
            guard let weakSelf = self else { return }

            DispatchQueue.main.async {
                if let events = events {
                    weakSelf.events = events
                    weakSelf.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
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
        return events.count
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
