//
//  WeatherDetailViewModelTests.swift
//  WeatherAppTests
//
//  Created by Dileepa Pathirana on 22/12/23.
//

import XCTest
import CoreData
@testable import WeatherApp

final class WeatherDetailViewModelTests: XCTestCase {
    
    class MockExDataController: ExtendedDataControllerProtocol {
        
        var container: NSPersistentContainer = NSPersistentContainer(name: "WeatherApp")
        
        var retrievedMockCity: CityManagedObject?
        var addedMockCity: CityManagedObject?
        
        func updateLastViewedTime(city: CityManagedObject, date: Date, viewContext: NSManagedObjectContext) {
            city.viewedTime = date
            city.name = "Bishan"
        }
        
        func retrieve(city: CityModel, viewContext: NSManagedObjectContext) -> CityManagedObject? {
            return retrievedMockCity
        }
        
        func addCity(model: CityModel, viewContext: NSManagedObjectContext) -> CityManagedObject {
            return addedMockCity!
        }
    }

    class MockWeatherAPIManager: WeatherAPIManagerProtocol {
        
        var apiUtil: APIUtilProtocol = APIUtil()
        var mockResult: WeatherDetailEntity?
        var mockError: Bool = false
        
        func getDetail(cityName: String) async throws -> WeatherDetailEntity? {
            
            if mockError {
                throw DataError.ServerError
            } else {
                return mockResult
            }
        }
    }

    var viewModel: WeatherDetailViewModel!
    var apiManager: MockWeatherAPIManager!
    var dataController: DataController!
    
    override func setUpWithError() throws {
        
        let amk = CityModel(id: UUID(), name: "Ang Mo Kio", country: "Singapore", region: "Singapore")
        apiManager = MockWeatherAPIManager()
        viewModel = WeatherDetailViewModel(currentCity: amk)
        dataController = DataController.shared
    }

    override func tearDownWithError() throws {
        
        viewModel = nil
        apiManager = nil
        dataController = nil
    }

    func testWeatherDetailViewModelCityModelIsSet() {
        
        XCTAssertNotNil(viewModel.currentCity)
    }

    func testWeatherDetailViewModelGetDetailSuccess() {
        
        // give
        let city = CityModel(id: UUID(), name: "Ang Mo Kio", country: "Singapore", region: "Singapore")
        let weatherEntity = WeatherDetailEntity(temp: "30", icon: "", weatherDesc: "Cloudy", humidity: "80")
        apiManager.mockResult = weatherEntity
        viewModel.apiManger = apiManager
        
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                try await viewModel.getWeatherDetails(for: city)
            } catch {
                XCTFail("Error")
            }
            
             await MainActor.run {
                XCTAssertNotNil(viewModel.weatherDetail)
                XCTAssertEqual(viewModel.weatherDetail?.tempC ?? "", "30")
                expectation.fulfill()
             }

        }
        
         wait(for: [expectation], timeout: 5.0)
    }
    
    func testWeatherDetailViewModelGetNil() {
        
        // give
        let city = CityModel(id: UUID(), name: "Ang Mo Kio", country: "Singapore", region: "Singapore")
        apiManager.mockResult = nil
        apiManager.mockError = false
        viewModel.apiManger = apiManager
        
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                try await viewModel.getWeatherDetails(for: city)
            } catch let error as DataError {
                XCTAssertEqual(error, DataError.BadData)
            } catch {
                XCTFail("Error")
            }
        
            await MainActor.run {
               expectation.fulfill()
            }

        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWeatherDetailViewModelGetDataError() {
        
        // give
        let city = CityModel(id: UUID(), name: "Ang Mo Kio", country: "Singapore", region: "Singapore")
        apiManager.mockError = true
        viewModel.apiManger = apiManager
        
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                try await viewModel.getWeatherDetails(for: city)
            } catch let error as DataError {
                XCTAssertEqual(error, DataError.ServerError)
            } catch {
                XCTFail("Error")
            }
            await MainActor.run {
               expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWeatherDetailViewModelSaveViewedCity() {

        let context = dataController.container.newBackgroundContext()
        let city = CityModel(id: UUID(), name: "Ang Mo Kio", country: "Singapore", region: "Singapore")
        let saved = CityManagedObject.init(name: "Ang Mo Kio", country: "Singapore", region: "Singapore", context: context)
        let mockDataController = MockExDataController()
        
        mockDataController.addedMockCity = saved
        mockDataController.retrievedMockCity = nil
        viewModel.dataController = mockDataController
        
        viewModel.saveViewedCity(city)
        
        XCTAssertNotNil(saved.viewedTime)
    }
    
    func testWeatherDetailViewModelUpdateViewedCity() {

        let context = dataController.container.newBackgroundContext()
        let city = CityModel(id: UUID(), name: "Ang Mo Kio", country: "Singapore", region: "Singapore")
        let saved = CityManagedObject.init(name: "Ang Mo Kio", country: "Singapore", region: "Singapore", context: context)
        let mockDataController = MockExDataController()
        
        mockDataController.retrievedMockCity = saved
        viewModel.dataController = mockDataController
        
        viewModel.saveViewedCity(city)
        
        XCTAssertEqual(saved.name, "Bishan")
    }
}
