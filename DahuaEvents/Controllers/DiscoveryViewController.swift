//
//  DiscoveryViewController.swift
//  ONVIFDiscovery
//
//  Created by mani on 2019-12-02.
//  Copyright © 2019 mani. All rights reserved.
//

import UIKit

class DiscoveryViewController: UITableViewController, NoContentBackground {
    private let reuseIdentifier = "DeviceCell"
    private var discoveredDevices = [ONVIFDiscovery]()
    private lazy var queryService = ONVIFQueryService()
    let backgroundView = TableBackgroundView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Devices"

        backgroundView.frame = view.frame
        backgroundView.messageLabel.text = "Peform device discovery"
        backgroundView.actionButtonTitle = "Start"
        backgroundView.handler = { [unowned self] in
            self.performDeviceDiscovery()
        }
        tableView.backgroundView = backgroundView
        hideBackgroundView()
    }
}

extension DiscoveryViewController {
    // MARK: - Discover devices

    func performDeviceDiscovery() {
        backgroundView.startLoadingOperation()

        getDevice { [unowned self] (device) in
            DispatchQueue.main.async {
                self.discoveredDevices.append(device)
                self.discoveredDevices.sort { $0.ipAddress < $1.ipAddress }
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)

                if self.discoveredDevices.count == 0 {
                    self.backgroundView.stopLoadingOperation()
                }
            }
        }
    }
}

extension DiscoveryViewController {
    // MARK: - ONVIF Queries

    func getDevice(completion: @escaping (ONVIFDiscovery) -> Void) {
        do {
            try queryService.performONVIFDiscovery { (discoveredDevice, error) in
                if let error = error {
                    debugLog("Error: \(error)")
                }
                if let discoveredDevice = discoveredDevice {
                    completion(discoveredDevice)
                }
            }
        } catch {
            debugLog("Failed to perform UDP broadcast")
        }
    }
}

extension DiscoveryViewController {
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

extension DiscoveryViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let deviceCount = discoveredDevices.count

        if (deviceCount > 0){
            hideBackgroundView()
        } else {
            showBackgroundView()
        }
        
        return discoveredDevices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        let device = discoveredDevices[indexPath.row]
        cell.textLabel?.textColor = .darkText
        cell.textLabel?.text = device.model
        cell.detailTextLabel?.text = device.ipAddress
        cell.isUserInteractionEnabled = true

        return cell
    }
}
