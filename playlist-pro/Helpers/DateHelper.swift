//
//  DateFormatter.swift
//  youtube-onedaybuild
//
//  Created by Aidan Lee on 11/2/20.
//

import Foundation

class DateHelper {
    
    static func getFormattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d, yyyy"
        return df.string(from: date)
    }
}
