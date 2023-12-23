//
//  WeatherDetailAPIManager.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 22/12/23.
//

import Foundation

protocol WeatherAPIManagerProtocol {
    
    var apiUtil: APIUtilProtocol {set get}
    func getDetail(cityName: String) async throws -> WeatherDetailEntity?
}

class WeatherDetailAPIManager: WeatherAPIManagerProtocol {
    
    static let shared = WeatherDetailAPIManager()
    var apiUtil: APIUtilProtocol = APIUtil()
    
    func getDetail(cityName: String) async throws -> WeatherDetailEntity? {
        
        let apiRequest = Constants.APIRequest.weatherDetail(query: cityName)
        
        var weatherDetail: WeatherDetailEntity?
        do {
            guard let decodedData: WeatherDetailData = try await apiUtil.fetch(for: apiRequest) else {
                throw DataError.BadData
            }
            weatherDetail = decodedData.data.currentCondition.first
        } catch let error {
            throw error
        }
        return weatherDetail

    }
    
}
