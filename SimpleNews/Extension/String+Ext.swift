//
//  String+Ext.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

extension String {
    func convertToDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "MMM dd, yyyy"
            return dateFormatter.string(from: date)
        } else {
            return self
        }
    }
    
    func convertFromISO8601Format() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "MMM dd, yyyy"
            return dateFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
    
}

