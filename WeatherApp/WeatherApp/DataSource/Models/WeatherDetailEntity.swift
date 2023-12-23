//
//  WeatherDetailModel.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 20/12/23.
//

import Foundation


struct WeatherDetailEntity: Codable, Hashable {
    
    let tempC: String
    let weatherIconUrl: String
    let weatherDesc: String
    let humidity: String
    
    enum RootKeys: String, CodingKey {
        case tempC, weatherIconUrl, weatherDesc, humidity
    }
    
    enum InfoKeys: String, CodingKey {
        case value
    }
    
    init(temp: String, icon: String, weatherDesc: String, humidity: String) {
        self.tempC = temp
        self.weatherIconUrl = icon
        self.weatherDesc = weatherDesc
        self.humidity = humidity
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        self.tempC = try container.decode(String.self, forKey: .tempC)
        
        self.humidity = try container.decode(String.self, forKey: .humidity)
        
        self.weatherIconUrl = try WeatherDetailEntity.getValue(from: container, forKey: .weatherIconUrl)
        self.weatherDesc = try WeatherDetailEntity.getValue(from: container, forKey: .weatherDesc)
        
    }
    
    static func getValue(from container: KeyedDecodingContainer<RootKeys>, forKey: KeyedDecodingContainer<RootKeys>.Key) throws -> String {
        
        var areaUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: forKey)
        var areasArray = [String]()
        while !areaUnkeyedContainer.isAtEnd {
            let areaContainer = try areaUnkeyedContainer.nestedContainer(keyedBy: InfoKeys.self)
            areasArray.append(try areaContainer.decode(String.self, forKey: .value))
        }
        
        return areasArray.first ?? ""
    }
}

struct WeatherCondition: Codable {
    let currentCondition: [WeatherDetailEntity]
}

struct WeatherDetailData: Codable {
    let data: WeatherCondition
}

