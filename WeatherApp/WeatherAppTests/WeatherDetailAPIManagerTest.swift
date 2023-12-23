//
//  WeatherDetailAPIManagerTest.swift
//  WeatherAppTests
//
//  Created by Dileepa Pathirana on 23/12/23.
//

import XCTest

final class WeatherDetailAPIManagerTest: XCTestCase {

    class MockAPIUtil: APIUtilProtocol {
        
        var urlSession: URLSessionProtocol = URLSession.shared
        static var shared: MockAPIUtil =  MockAPIUtil()
        var mockResult: WeatherDetailData?
        var mockError: Bool = false
        
        func fetch<T: Codable>(for request: Constants.APIRequest?) async throws -> T?  where T : Codable {
            
            if mockError {
                throw DataError.ServerError
            } else {
                return mockResult as? T
            }
        }
    }

    var manager: WeatherAPIManagerProtocol!
    override func setUpWithError() throws {
        manager = WeatherDetailAPIManager()
    }

    override func tearDownWithError() throws {
        manager = nil
    }
    
    func testWeatherDetailAPIManagerRequestError() {

        let apiUtil = MockAPIUtil.shared
        apiUtil.mockResult = nil
        apiUtil.mockError = false
        manager.apiUtil = apiUtil
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                let weatherData: WeatherDetailEntity? = try await manager.getDetail(cityName: "AMK")
                if weatherData != nil {
                    XCTFail("Error")
                }
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

    func testWeatherDetailAPIManagerGetDetailReturnData() {
        
        let weatherEntity = WeatherDetailEntity(temp: "30", icon: "", weatherDesc: "Cloudy", humidity: "80")
        let condition = WeatherCondition(currentCondition: [weatherEntity])
        let dataEntity = WeatherDetailData(data: condition)
        let apiUtil = MockAPIUtil.shared
        apiUtil.mockResult = dataEntity
        apiUtil.mockError = false
        manager.apiUtil = apiUtil
        
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                if let weatherData: WeatherDetailEntity = try await manager.getDetail(cityName: "AMK") {
                    XCTAssertEqual(weatherData.tempC, "30")
                } else {
                    XCTFail("Error")
                }
            } catch {
                XCTFail("Error")
            }
            
            await MainActor.run {
               expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWeatherDetailAPIManagerRequestReturnNil() {

        let apiUtil = MockAPIUtil.shared
        apiUtil.mockResult = nil
        apiUtil.mockError = false
        manager.apiUtil = apiUtil
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                let weatherData: WeatherDetailEntity? = try await manager.getDetail(cityName: "AMK")
                if weatherData != nil {
                    XCTFail("Error")
                }
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
    
    func testWeatherDetailAPIManagerRequestReturnError() {

        let apiUtil = MockAPIUtil.shared
        apiUtil.mockError = true
        manager.apiUtil = apiUtil
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                let _: WeatherDetailEntity? = try await manager.getDetail(cityName: "AMK")
                XCTFail("Error")
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


}
