//
//  DataController.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 19/12/23.
//

import CoreData

protocol DataControllerProtocol {
    
    func fetchLastViewed(limit: Int) -> [CityManagedObject]?
}

protocol ExtendedDataControllerProtocol {
    
    var container: NSPersistentContainer { get set }
    func retrieve(city: CityModel, viewContext: NSManagedObjectContext) -> CityManagedObject?
    func addCity(model: CityModel, viewContext: NSManagedObjectContext) -> CityManagedObject
    func updateLastViewedTime(city: CityManagedObject, date: Date, viewContext: NSManagedObjectContext)
}

struct DataController: DataControllerProtocol, ExtendedDataControllerProtocol {
    
    var container: NSPersistentContainer
    static let shared = DataController()
    
    static var preview: DataController = {
        let result = DataController(inMemory: true)
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WeatherApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save(context: NSManagedObjectContext) {
        
        do {
            try context.save()
        } catch {
            print("Error in data saving")
        }
    }
    
    func retrieve(city: CityModel, viewContext: NSManagedObjectContext) -> CityManagedObject? {
        
        let fetchRequest: NSFetchRequest<CityManagedObject> = NSFetchRequest<CityManagedObject>(entityName: "CityManagedObject")
        fetchRequest.predicate = NSPredicate(format: "name == %@ && country == %@ ", city.name, city.country)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching object: \(error)")
            return nil
        }
    }
    
    func fetchLastViewed(limit: Int) -> [CityManagedObject]? {
        
        let fetchRequest: NSFetchRequest<CityManagedObject> = NSFetchRequest<CityManagedObject>(entityName: "CityManagedObject")
        let sortDescriptor = NSSortDescriptor(key: "viewedTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = limit
        
        do {
            let results: [CityManagedObject] = try self.container.viewContext.fetch(fetchRequest)
            return results
        } catch {
            print("Error fetching object: \(error)")
            return nil
        }
    }
    
    func addCity(model: CityModel, viewContext: NSManagedObjectContext) -> CityManagedObject {
        let city = CityManagedObject(name: model.name, country: model.country, region: model.region, context: viewContext)
        save(context: self.container.viewContext)
        return city
    }
    
    func updateLastViewedTime(city: CityManagedObject, date: Date, viewContext: NSManagedObjectContext) {
        city.viewedTime = date
        save(context: viewContext)
    }
    
}


