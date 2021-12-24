//
//  HTTPClient.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 22/12/2021.
//

import Foundation
import UIKit

struct APIPath {
    static let apiKey = "91rxquhTeUZ3q9fjxLtsTVkfuj66kBddHRmYH9ko"
    static let baseURL = "api.nasa.gov"
    static let astronomyPOD = "/planetary/apod"
}

class NasaHTTPClient {
    static let shared = NasaHTTPClient()
    
    public func getAPODs(queryParams: [String: String]?, completion: @escaping ([APOD]?,Error?) -> Void) {
        let url = APIPath.astronomyPOD
        RequestAPI<[APOD]>.get(path: url, queryParams: queryParams) { data, error in
            completion(data,error)
        }
    }
    
    public func getSingleAPOD(queryParams: [String: String]?, completion: @escaping (APOD?,Error?) -> Void) {
        let url = APIPath.astronomyPOD
        RequestAPI<APOD>.get(path: url, queryParams: queryParams) { data, error in
            completion(data,error)
        }
    }
}



