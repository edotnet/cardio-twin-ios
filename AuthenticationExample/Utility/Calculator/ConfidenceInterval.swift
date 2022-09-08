//
//  ConfidenceInterval.swift
//  AuthenticationExample
//
//  Created by edik on 04.09.22.
//  Copyright © 2022 Firebase. All rights reserved.
//

import Foundation

class ConfidenceInterval {
    var Point: Float?
    var Low: Float?
    var High: Float?
    
    init(point: Float, low: Float, high: Float) {
        Point = point
        Low = low
        High = high
    }
}
