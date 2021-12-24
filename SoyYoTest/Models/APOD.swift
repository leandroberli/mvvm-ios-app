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
}
