//
//  Channel.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-11.
//  Copyright © 2020 mani. All rights reserved.
//

import Foundation

struct Channel: Codable, Equatable {
    var name: String
    var number: String

    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.number == rhs.number
    }
}
