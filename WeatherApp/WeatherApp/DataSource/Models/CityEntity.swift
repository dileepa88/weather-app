//
//  CityEntity.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 19/12/23.
//

import Foundation

enum WeatherError: Error {
    case decodingError
}

struct CityEntity: Codable {
    
    var id: UUID
    let areaName: String
    let country: String
    let region: String
    
    enum RootKeys: String, CodingKey {
        case areaName, country, region
    }
    
    enum InfoKeys: String, CodingKey {
        case value
    }
    
    init(id: UUID, areaName: String, country: String, region: String) {
        self.id = id
        self.areaName = areaName
        self.country = country
        self.region = region
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        self.areaName = try CityEntity.getValue(from: container, forKey: .areaName)
        self.country = try CityEntity.getValue(from: container, forKey: .country)
        self.region = try CityEntity.getValue(from: container, forKey: .region)
        self.id = UUID()
        
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

struct CityResultModel: Codable {
    let result: [CityEntity]
}

struct CitySearchData: Codable {
    let searchApi: CityResultModel
}

