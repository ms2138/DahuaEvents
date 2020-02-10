//
//  Event.swift
//  DahuaEvents
//
//  Created by mani on 2020-02-09.
//  Copyright © 2020 home. All rights reserved.
//

import Foundation

struct Event: Comparable {
    var startTime: String
    var endTime: String
    var type: String
    var fileType: String
    var filePath: String
    var channel: String
    var playbackURL: URL

    static func < (lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime < rhs.endTime
    }

    static func > (lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime > rhs.endTime
    }

    static func <= (lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime <= rhs.endTime
    }

    static func >= (lhs: Event, rhs: Event) -> Bool {
        return lhs.startTime >= rhs.endTime
    }
}
