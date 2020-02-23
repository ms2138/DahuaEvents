//
//  ChannelViewController.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-16.
//  Copyright © 2020 mani. All rights reserved.
//

import UIKit

class ChannelViewController: UITableViewController {
    var device: ONVIFDiscovery?
    private var channels = [Channel]()
    private var credential: Credential?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Channels"

        showAuthenticationController { [weak self] (username, password) in
            guard let weakSelf = self else { return }

            if let username = username, let password = password,
                let device = weakSelf.device {

                weakSelf.createDevice(from: device.ipAddress,
                                      username: username,
                                      password: password,
                                      completion: { (device, credential) in

                                        weakSelf.credential = credential

                                         if let device = device {
                                            device.channels.forEach { channel in
                                                let dahuaQuery = DahuaQueryService(host: device.address,
                                                                                   username: credential.username,
                                                                                   password: credential.password)
                                                // Make a call to getAutoFocusStatus to ensure that the channel is active
                                                dahuaQuery.getAutoFocusStatus(for: channel.number) { (_, error) in

                                                    if error == nil {
                                                        weakSelf.channels.append(channel)

                                                        weakSelf.channels.sort { $0.number < $1.number }

                                                        DispatchQueue.main.async {
                                                            weakSelf.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                })
            }
        }
    }
}

extension ChannelViewController {
    func createDevice(from host: String, username: String, password: String,
                      completion: @escaping (DahuaDevice?, Credential) -> Void) {
        let dahuaQuery = DahuaQueryService(host: host,
                                           username: username,
                                           password: password)
        let credential = Credential(username: username, password: password)

        // Get device name
        dahuaQuery.getType { [weak self] (deviceType, error) in
            guard let weakSelf = self else { return }
            if let deviceType = deviceType {
                // Get serial number
                dahuaQuery.getSerialNumber(completion: { (serialNumber, _) in
                    if let serialNumber = serialNumber {
                        // Get device channel titles
                        dahuaQuery.getChannel(completion: { (channels, _) in
                            if let channels = channels {
                                let device = DahuaDevice(type: deviceType,
                                                         address: host,
                                                         serial: serialNumber,
                                                         channels: channels)
                                DispatchQueue.main.async {
                                    completion(device, credential)
                                }
                            }
                        })
                    }
                })
            } else {
                if let error = error {
                    DispatchQueue.main.async {
                        weakSelf.showErrorAlertController(error.localizedDescription)
                    }
                }
            }
        }
    }

    func getRTSPStreamURL(from host: String, credential: Credential, channel: String, streamType: String) -> URL? {
        let dahuaAPI = DahuaAPI(host: host,
                                username: credential.username,
                                password: credential.password)

        return dahuaAPI.getRTSPStreamURL(channel: channel, streamType: streamType)
    }
}

extension ChannelViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)

        if channels.count > 0 {
            let channel = channels[indexPath.row]
            cell.textLabel?.text = channel.name
            cell.detailTextLabel?.text = "Channel \(channel.number)"
        }

        return cell
    }
}

extension ChannelViewController {
// MARK: - Authentication and Alerts

    private func showAuthenticationController(completion: @escaping (String?, String?) -> Void) {
        let alertController = UIAlertController(title: "Authentication Required", message: nil, preferredStyle: .alert)
        let notificationCenter = NotificationCenter.default

        var token: Any?

        let authenticateAction = UIAlertAction(title: "Authenticate", style: .default) { (_) in
            let usernameTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField

            notificationCenter.removeObserver(token!)

            completion(usernameTextField.text, passwordTextField.text)
        }
        authenticateAction.isEnabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            notificationCenter.removeObserver(token!)
            completion(nil, nil)
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Username"

            token = notificationCenter.addObserver(forName: UITextField.textDidChangeNotification,
                                                   object: textField,
                                                   queue: OperationQueue.main) { (_) in
                                                    authenticateAction.isEnabled = textField.text != ""
            }
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }

        alertController.addAction(authenticateAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func showErrorAlertController(_ title: String) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

extension ChannelViewController {
    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "showEvents":
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: selectedIndexPath, animated: true)
                    guard let eventsViewController = segue.destination as?
                        EventsViewController else { return }

                    let channel = channels[selectedIndexPath.row]
                    if let device = device, let credential = credential {
                        if let url = self.getRTSPStreamURL(from: device.ipAddress,
                                                           credential: credential,
                                                           channel: channel.number,
                                                           streamType: "0") {
                            eventsViewController.videoStreamURL = url
                        }
                    }
            }
            default:
                preconditionFailure("Segue identifier did not match")
        }
    }
}
