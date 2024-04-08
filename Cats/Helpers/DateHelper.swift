//
//  DateHelper.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import Foundation

struct DateHelper {
    static let shared = DateHelper()
    
    private let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
    private init() { }
    
    func formatToMediumDate(_ date: Date) -> String {
        return mediumDateFormatter.string(from: date)
    }
    
}

