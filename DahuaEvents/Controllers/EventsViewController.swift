//
//  EventsViewController.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-09.
//  Copyright © 2020 mani. All rights reserved.
//

import UIKit

class EventsViewController: UITableViewController {
    var videoStreamURL: String?
    private var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
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
