//
//  APIUtil.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 21/12/23.
//

import Foundation

protocol URLSessionProtocol {
    func data(form request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {

    func data(form request: URLRequest) async throws -> (Data, URLResponse) {
        return try await data(for: request)
    }
}

protocol APIUtilProtocol {
    
    var urlSession: URLSessionProtocol {set get}
    func fetch<T: Codable>(for urlRequest: Constants.APIRequest?) async throws -> T? where T : Codable
}

class APIUtil: APIUtilProtocol {
    
    var urlSession: URLSessionProtocol = URLSession.shared
        
    func fetch<T: Codable>(for request: Constants.APIRequest?) async throws -> T? where T : Codable {
        
        guard let urlRequest = request?.buildURLRequest() else { throw DataError.BadRequest}
                
        let (data, response) = try await urlSession.data(form: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        var decodedData: T?
        do {
            let result = try decoder.decode(T.self, from: data)
            decodedData = result
        } catch {
            throw DataError.BadData
        }
        
        return decodedData
    }
}
