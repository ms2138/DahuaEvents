//
//  DahuaDevice.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-16.
//  Copyright © 2020 home. All rights reserved.
//

import Foundation

struct DahuaDevice {
    var type: String
    var address: String
    var serial: String
    var channels: [Channel]
}
