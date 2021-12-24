//
//  HTTPHelpers.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 22/12/2021.
//

import Foundation

public struct RequestAPI<Model: Codable> {
    public typealias finishTaskCallback = (_ response: Model?, _ error: Error?) -> Void
    
    static func get(path: String, queryParams: [String: String]? = nil, success finishCallback: @escaping finishTaskCallback ) {
        
        var urlComps = URLComponents()
        urlComps.scheme = "https"
        urlComps.host = APIPath.baseURL
        urlComps.path = path
        
        var queryItems = [URLQueryItem]()
        //Add query params if needed
        if let params = queryParams {
            params.forEach({ param in
                let queryItem = URLQueryItem(name: param.key, value: param.value)
                queryItems.append(queryItem)
            })
        }
        //Add API Key as query item
        let apiKeyQueryItem = URLQueryItem(name: "api_key", value: APIPath.apiKey)
        queryItems.append(apiKeyQueryItem)
        //set query items to url
        urlComps.queryItems = queryItems
        
        guard let url = urlComps.url else {
            finishCallback(nil,nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        var dataTask: URLSessionDataTask?
        let defaultSession = URLSession(configuration: .default)
        
        dataTask = defaultSession.dataTask(with: request) { data, response, error in
            print(#function, "PATH: " + path)
            if let err = error {
                print(err.localizedDescription)
                finishCallback(nil, error)
            } else if let data = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200 {
                let str = String(data: data, encoding: .utf8)
                print(str)
                guard let model = self.parseModel(with: data) else {
                    finishCallback(nil, nil)
                    return
                }
                finishCallback(model,nil)
            }
        }
        dataTask?.resume()
    }
    
    static func parseModel(with data: Data) -> Model? {
        do {
            let decoder = JSONDecoder()
            let model = try decoder.decode(Model.self, from: data)
            return model
        } catch {
            print(error)
            return nil
        }
    }
}

