//
//  DataControllerTests.swift
//  WeatherAppTests
//
//  Created by Dileepa Pathirana on 24/12/23.
//

import XCTest
import CoreData
@testable import WeatherApp

final class DataControllerTests: XCTestCase {

    var dataController: DataController!
    
    lazy var persistentContainer: NSPersistentContainer = {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            let container = NSPersistentContainer(name: "WeatherApp")
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
    
    override func setUpWithError() throws {
        
        dataController = DataController.shared
    }

    override func tearDownWithError() throws {
        
        dataController = nil
    }

   /* func testDataControllerRetrieve() {
        
        let context = persistentContainer.newBackgroundContext()
        //dataController.container = persistentContainer
        let city = CityModel(id: UUID(), name: "Ang Mo", country: "Singapore", region: "Singapore")
        //let cityManagedObject = CityManagedObject(name: "Ang Mo", country: "Singapore", region: "Singapore", context: context)
        
        let saved = dataController.addCity(model: city, viewContext: context)
        let retrieved = dataController.retrieve(city: city, viewContext: context)
        
        //XCTAssertNotNil(saved)
        XCTAssertEqual(retrieved?.name, "Ang Mo")

    
    }*/
}
