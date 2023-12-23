//
//  Constants.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 21/12/23.
//

import Foundation


struct Constants {
    
    static let timeOutInterval: Double = 20.0
    static let previouslyViewedLimit: Int = 10
    
    static let weatherApiBaseURL: String = "https://api.worldweatheronline.com/premium/v1"
    static let WEATHER_API_KEY: String = "9d205c55d31442f8850123326231912"
    
    enum APIRequest {
        
        case searchCity(query: String)
        case weatherDetail(query: String)
        
        func buildURLRequest() -> URLRequest? {
            switch self {
            case .searchCity(let query):
                
                guard let baseUrl = URL.init(string: Constants.weatherApiBaseURL + "/search.ashx") else { return nil }
                
                let apiKey = URLQueryItem(name: "key", value: Constants.WEATHER_API_KEY)
                let query = URLQueryItem(name: "q", value: query)
                let format = URLQueryItem(name: "format", value: "json")
                let url = baseUrl.appending(queryItems: [apiKey, query, format])
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                return request
                
            case .weatherDetail(let query):
                
                guard let baseUrl = URL.init(string: Constants.weatherApiBaseURL + "/weather.ashx") else { return nil }
                
                let apiKey = URLQueryItem(name: "key", value: Constants.WEATHER_API_KEY)
                let query = URLQueryItem(name: "q", value: query)
                let format = URLQueryItem(name: "format", value: "json")
                let noOfDays = URLQueryItem(name: "num_of_days", value: "1")
                
                let url = baseUrl.appending(queryItems: [apiKey, query, format, noOfDays])
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                return request
            }
        }
    }
}

enum DataError: Error {
    case ShortKeyWord, BadRequest, BadData, ServerError
}
