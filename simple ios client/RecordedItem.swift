//
//  RecordedItems.swift
//  simple ios client
//
//  Created by Thomas Garske on 12/12/16.
//  Copyright © 2016 csci4211. All rights reserved.
//

import UIKit

class RecordedItem {
    let value : String
    let timestamp : String
    let date : Date
    init(val : Double, time : Date, type : String) {
        value = String.init(format: "%.2f %@ Per Minute", val, type)
        let formatt = DateFormatter()
        formatt.dateStyle = .long
        formatt.timeStyle = .short
        timestamp = formatt.string(from: time)
        date = time
    }
}
