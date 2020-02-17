//
//  Credential.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-16.
//  Copyright © 2020 home. All rights reserved.
//

import Foundation

struct Credential {
    var username: String
    var password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
