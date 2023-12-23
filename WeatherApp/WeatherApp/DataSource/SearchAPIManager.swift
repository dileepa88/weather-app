//
//  APIManager.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 20/12/23.
//

import Foundation

protocol SearchAPIManagerProtocol {
    var apiUtil: APIUtilProtocol {set get}
    func search(by cityName: String) async throws -> [CityEntity]
}

class SearchAPIManager: SearchAPIManagerProtocol {
    
    static let shared = SearchAPIManager()
    var apiUtil: APIUtilProtocol = APIUtil()

    func search(by cityName: String) async throws -> [CityEntity] {
        
        let apiRequest = Constants.APIRequest.searchCity(query: cityName)

        var cities: [CityEntity] = []
        do {
            guard let decodedData: CitySearchData = try await apiUtil.fetch(for: apiRequest) else {
                throw DataError.BadData
            }
            cities = decodedData.searchApi.result
        } catch let error {
            throw error
        }
        
        return cities
    }
}
