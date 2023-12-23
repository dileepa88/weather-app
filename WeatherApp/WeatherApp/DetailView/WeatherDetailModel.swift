//
//  WeatherDetailModel.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 21/12/23.
//

import Foundation


struct WeatherDetailModel {
    
    let tempC: String
    let weatherIconUrl: String
    let weatherDesc: String
    let humidity: String
    
    init(entity: WeatherDetailEntity) {
        
        self.tempC = entity.tempC
        self.weatherIconUrl = entity.weatherIconUrl
        self.weatherDesc = entity.weatherDesc
        self.humidity = entity.humidity
    }
    
}
