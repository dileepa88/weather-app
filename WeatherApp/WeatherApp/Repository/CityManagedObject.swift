//
//  CityManagedObject.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 21/12/23.
//

import Foundation
import CoreData

class CityManagedObject: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var country: String
    @NSManaged var region: String
    @NSManaged var viewedTime: Date
    
    
    convenience init(name: String, country: String, region: String, context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "CityManagedObject", in: context)!
        self.init(entity: entityDescription, insertInto: context)
        self.name = name
        self.country = country
        self.region = region
        self.viewedTime = Date()
    }
}
