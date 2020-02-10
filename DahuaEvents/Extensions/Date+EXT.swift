//
//  Date+EXT.swift
//  CameraViewer
//
//  Created by mani on 2019-10-19.
//  Copyright © 2019 mani All rights reserved.
//

import Foundation

extension Date {
    func dateString(dateStyle: DateFormatter.Style = .medium,
                    timeStyle: DateFormatter.Style = .medium,
                    format: String = "yyyy-M-d hh:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    func localString(dateStyle: DateFormatter.Style = .medium,
                     timeStyle: DateFormatter.Style = .medium) -> String {
        return DateFormatter.localizedString(
            from: self,
            dateStyle: dateStyle,
            timeStyle: timeStyle)
    }

    var startOfDay: Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.startOfDay(for: self)
    }

    var nextDay: Date? {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.startOfDay(for: self)
        return calendar.date(byAdding: .day, value: 1, to: date)
    }
}
