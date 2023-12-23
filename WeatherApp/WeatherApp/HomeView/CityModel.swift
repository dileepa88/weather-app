//
//  CityModel.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 21/12/23.
//

import Foundation

struct CityModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let country: String
    let region: String
    
    var fullName: String {
        return (name) + " " + country
    }
    
    init(id: UUID, name: String, country: String, region: String) {
        
        self.id = id
        self.name = name
        self.country = country
        self.region = region
    }
    
    init(entity: CityEntity) {
        self.id = entity.id
        self.name = entity.areaName
        self.country = entity.country
        self.region = entity.region
    }
    
    init(manageObj: CityManagedObject) {
        
        self.id = UUID()
        self.name = manageObj.name
        self.country = manageObj.country
        self.region = manageObj.region
    }
}
