//
//  SearchAPIManagerTests.swift
//  WeatherAppTests
//
//  Created by Dileepa Pathirana on 23/12/23.
//

import XCTest

final class SearchAPIManagerTests: XCTestCase {
    
    class MockAPIUtil: APIUtilProtocol {
        
        var urlSession: URLSessionProtocol = URLSession.shared
        static var shared: MockAPIUtil =  MockAPIUtil()
        var mockResult: CitySearchData?
        var mockError: Bool = false
        
        func fetch<T: Codable>(for request: Constants.APIRequest?) async throws -> T?  where T : Codable {
            
            if mockError {
                throw DataError.ServerError
            } else {
                return mockResult as? T
            }
        }
    }

    var manager: SearchAPIManagerProtocol!
    override func setUpWithError() throws {

        manager = SearchAPIManager()
    }

    override func tearDownWithError() throws {
        
        manager = nil
    }
    
//    func testSearchAPIManageSearchRequestError() {
//
//        let apiUtil = MockAPIUtil.shared
//        apiUtil.mockResult = nil
//        apiUtil.mockError = false
//        manager.apiUtil = apiUtil
//        let expectation = XCTestExpectation(description: "Search Expectation")
//        
//        Task {
//            
//            do {
//                let _: [CityEntity] = try await manager.search(by: "AMK")
//                XCTFail("Error")
//            } catch let error as DataError {
//                XCTAssertEqual(error, DataError.BadRequest)
//            } catch {
//                XCTFail("Error")
//            }
//            
//            await MainActor.run {
//               expectation.fulfill()
//            }
//        }
//        
//        wait(for: [expectation], timeout: 5.0)
//    }

    func testSearchAPIManageSearchRequestReturnData() {
        
        let city1 = CityEntity(id: UUID(), areaName: "aaa", country: "AAA", region: "aaaAAA")
        let city2 = CityEntity(id: UUID(), areaName: "bbb", country: "BBB", region: "aaaBBB")
        let city3 = CityEntity(id: UUID(), areaName: "ccc", country: "BBB", region: "aaaBBB")
        let cityList: [CityEntity] = [city1, city2, city3]
        let cityListResult : CityResultModel = CityResultModel(result: cityList)
        let cityData: CitySearchData = CitySearchData(searchApi: cityListResult)
        
        let apiUtil = MockAPIUtil.shared
        apiUtil.mockResult = cityData
        manager.apiUtil = apiUtil
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                let cityResults: [CityEntity] = try await manager.search(by: "AMK")
                XCTAssertEqual(cityResults.count, cityData.searchApi.result.count)
                
            } catch {
                XCTFail("Error")
            }
            
            await MainActor.run {
               expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSearchAPIManageSearchRequestReturnNil() {

        let apiUtil = MockAPIUtil.shared
        apiUtil.mockResult = nil
        apiUtil.mockError = false
        manager.apiUtil = apiUtil
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                let _: [CityEntity] = try await manager.search(by: "AMK")
                XCTFail("Error")
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
    
    func testSearchAPIManageSearchRequestReturnError() {

        let apiUtil = MockAPIUtil.shared
        apiUtil.mockError = true
        manager.apiUtil = apiUtil
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                let _: [CityEntity] = try await manager.search(by: "AMK")
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
