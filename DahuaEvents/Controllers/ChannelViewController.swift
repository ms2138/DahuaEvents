//
//  ChannelViewController.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-16.
//  Copyright © 2020 mani. All rights reserved.
//

import UIKit

class ChannelViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ChannelViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
}
