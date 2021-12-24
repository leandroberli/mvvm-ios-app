//
//  APOD.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 23/12/2021.
//

import Foundation

struct GenericResponse: Codable {
    
}

struct APOD: Codable {
    var copyright: String?
    var date: String
    var explanation: String
    var hdurl: String
    var media_type: String
    var service_version: String
    var title: String
    var url: String
    
    func getDateString() -> String {
        let inputFormat = DateFormatter()
        inputFormat.dateFormat = "yyyy-MM-dd"
        guard let inputDate = inputFormat.date(from: self.date) else {
            return "Unknown date"
        }
        
        let outformat = DateFormatter()
        outformat.dateFormat = "MMM d, yyyy"
        let str = outformat.string(from: inputDate)
        return str
    }
}

extension Date {
    func getQueryParamDateString() -> String {
        let inputFormat = DateFormatter()
        inputFormat.dateFormat = "yyyy-MM-dd"
        return inputFormat.string(from: self)
    }
    
    func getFilterDateString() -> String {
        let inputFormat = DateFormatter()
        inputFormat.dateFormat = "MMM d, yyyy"
        return inputFormat.string(from: self)
    }
}

extension String {
    /*func getDateObject() -> Date? {
        let inputFormat = DateFormatter()
        inputFormat.dateFormat = "yyyy-MM-dd"
    }*/
}
