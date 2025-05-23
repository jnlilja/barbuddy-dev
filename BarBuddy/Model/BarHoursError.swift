//
//  BarHoursError.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/20/25.
//

import Foundation

enum BarHoursError: Error {
    case invalidDateFormat
    case invalidTimeFormat
    case invalidDayOfWeek
    case invalidHourRange
    case failedPatchedRequest
    case doesNotExist(String)
}
