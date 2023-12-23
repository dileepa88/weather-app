//
//  HomeViewModelTests.swift
//  WeatherAppTests
//
//  Created by Dileepa Pathirana on 22/12/23.
//

import XCTest
import CoreData
@testable import WeatherApp

final class HomeViewModelTests: XCTestCase {
    
    class MockDataController: DataControllerProtocol {
        
        var mockData: [CityManagedObject]?
        func fetchLastViewed(limit: Int) -> [CityManagedObject]? {
            return mockData
        }
    }

    class MockSearchAPIManager: SearchAPIManagerProtocol {
                
        var apiUtil: APIUtilProtocol = APIUtil()
        var mockResult: [CityEntity]?
        
        func search(by cityName: String) async throws -> [CityEntity] {
            
            if let result = mockResult {
                return result
            } else {
                throw DataError.BadData
            }
        }
    }
    
    var viewModel: HomeViewModel!
    var apiManager: MockSearchAPIManager!
    var dataController: DataController!
    
    override func setUpWithError() throws {

        viewModel = HomeViewModel()
        apiManager = MockSearchAPIManager()
        dataController = DataController.shared
    }

    override func tearDownWithError() throws {
       
        viewModel = nil
        apiManager = nil
        dataController = nil
    }

    
    func testHomeViewModelShouldSearchWhenTextIsGreaterThanTwo() {
        
        // when
        viewModel.searchText = "Ang Mo Kio"
        // then
        XCTAssertTrue(viewModel.shouldSearch)
        
        let loopCount: Int = Int.random(in: 3..<50)
        for i in 3...loopCount {
            //when
            viewModel.searchText = generateRandomString(length: i)
            
            //then
            XCTAssertTrue(viewModel.shouldSearch)
        }
        
    }
    
    func testHomeViewModelShouldSearchWhenTextIsLessThanOrEqualToTwo() {
        // when
        viewModel.searchText = "An"
        // then
        XCTAssertFalse(viewModel.shouldSearch)
        
        // when
        viewModel.searchText = "A"
        // then
        XCTAssertFalse(viewModel.shouldSearch)
    }
    
    func testHomeViewModelShouldShowPastList() {
        // when
        viewModel.searchText = ""
        // then
        XCTAssertTrue(viewModel.shouldShowPastList)
    }
    
    
    func testHomeViewModelGeneratePastListNil() {
        // given
        let cityList: [CityManagedObject]? = nil
        let mockDataController = MockDataController()
        
        // when
        mockDataController.mockData = cityList
        viewModel.dataController = mockDataController
        
        // act
        viewModel.generatePastList()
        
        // then
        XCTAssertTrue(viewModel.cityList.isEmpty)
    }
    
    func testHomeViewModelGeneratePastListEmpty() {
        // given
        let cityList: [CityManagedObject] = []
        let mockDataController = MockDataController()
        
        // when
        mockDataController.mockData = cityList
        viewModel.dataController = mockDataController
        
        // act
        viewModel.generatePastList()
        
        // then 
        XCTAssertTrue(viewModel.cityList.isEmpty)
    }
    
    func testHomeViewModelGeneratePastListHasData() {
       
        // given
        let mockDataController = MockDataController()
        
        let context = dataController.container.newBackgroundContext()
        
        let city1 = CityManagedObject.init(name: "aaa", country: "AAA", region: "bbbBBB", context: context)
        let city2 = CityManagedObject.init(name: "bbb", country: "BBB", region: "bbbBBB", context: context)
        let city3 = CityManagedObject.init(name: "ccc", country: "BBB", region: "bbbBBB", context: context)
        let cityList: [CityManagedObject] = [city1, city2, city3]
    
        // when
        mockDataController.mockData = cityList
        viewModel.dataController = mockDataController
        
        // act
        viewModel.generatePastList()
        
        // then
        XCTAssertFalse(viewModel.cityList.isEmpty)
        XCTAssertEqual(viewModel.cityList.count, 3)
    }
    
    func testHomeViewModelSearchAsTypeSetTypingTrue() {
        
        //given
        let mockDataController = MockDataController()
        viewModel.dataController = mockDataController
        
        // when
        let expectation = XCTestExpectation(description: "Search As Type Expectation")
        
        Task {
            
            do {
                try await viewModel.searchAsType()
            } catch {
                XCTFail("Error")
            }
            
            await MainActor.run {
                XCTAssertTrue(viewModel.isTyping)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
        
    func testHomeViewModelSearchAsTypeGetSuccess() {
        
        // give
        viewModel.searchText = "Ang Mo Kio"
        
        let city1 = CityEntity(id: UUID(), areaName: "aaa", country: "AAA", region: "aaaAAA")
        let city2 = CityEntity(id: UUID(), areaName: "bbb", country: "BBB", region: "aaaBBB")
        let city3 = CityEntity(id: UUID(), areaName: "ccc", country: "BBB", region: "aaaBBB")
        
        let mockDataController = MockDataController()
        viewModel.dataController = mockDataController
        
        apiManager.mockResult = [city1, city2, city3]
        viewModel.apiManger = apiManager
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                try await viewModel.searchAsType()
            } catch {
                XCTFail("Error")
            }
            
            await MainActor.run {
                XCTAssertFalse(viewModel.cityList.isEmpty)
                XCTAssertEqual(viewModel.cityList.count, 3)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testHomeViewModelSearchAsTypeGetError() {
        
        // give
        viewModel.searchText = "Ang Mo Kio"
        let mockDataController = MockDataController()
        viewModel.dataController = mockDataController
        
        apiManager.mockResult = nil
        viewModel.apiManger = apiManager
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                try await viewModel.searchAsType()
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
    
    func testHomeViewModelSearchWithValidResult() {
        
        // give
        let city1 = CityEntity(id: UUID(), areaName: "aaa", country: "AAA", region: "aaaAAA")
        let city2 = CityEntity(id: UUID(), areaName: "bbb", country: "BBB", region: "aaaBBB")
        let city3 = CityEntity(id: UUID(), areaName: "ccc", country: "BBB", region: "aaaBBB")
        apiManager.mockResult = [city1, city2, city3]
        viewModel.apiManger = apiManager
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                try await viewModel.search()
            } catch {
                XCTFail("Error")
            }
            
            await MainActor.run {
                XCTAssertFalse(viewModel.cityList.isEmpty)
                XCTAssertEqual(viewModel.cityList.count, 3)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testHomeViewModelSearchWithError() {
        
        apiManager.mockResult = nil
        viewModel.apiManger = apiManager
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                try await viewModel.search()
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
    
    func testHomeViewModelRunSearchSetTypingFalse() {
        
        //given
        viewModel.searchText = "Ang Mo Kio"
        let mockDataController = MockDataController()
        viewModel.dataController = mockDataController
        
        // when
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                try await viewModel.runSearch()
            } catch {
                XCTFail("Error")
            }
            
            await MainActor.run {
                XCTAssertFalse(viewModel.isTyping)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testHomeViewModelRunSearchGetKeyWordError() {
        
        //given
        viewModel.searchText = "An"
        let mockDataController = MockDataController()
        viewModel.dataController = mockDataController
        
        // when
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                try await viewModel.runSearch()
            } catch let error as DataError {
                XCTAssertEqual(error, DataError.ShortKeyWord)
            }  catch {
                XCTFail("Error")
            }
            
            await MainActor.run {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testHomeViewModelRunSearchGetSuccess() {
        
        // give
        viewModel.searchText = "Ang Mo Kio"
        
        let city1 = CityEntity(id: UUID(), areaName: "aaa", country: "AAA", region: "aaaAAA")
        let city2 = CityEntity(id: UUID(), areaName: "bbb", country: "BBB", region: "aaaBBB")
        let city3 = CityEntity(id: UUID(), areaName: "ccc", country: "BBB", region: "aaaBBB")
        
        let mockDataController = MockDataController()
        viewModel.dataController = mockDataController
        
        apiManager.mockResult = [city1, city2, city3]
        viewModel.apiManger = apiManager
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                try await viewModel.runSearch()
            } catch {
                XCTFail("Error")
            }
            
            await MainActor.run {
                XCTAssertFalse(viewModel.cityList.isEmpty)
                XCTAssertEqual(viewModel.cityList.count, 3)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testHomeViewModelRunSearchGetError() {
        
        // give
        viewModel.searchText = "Ang Mo Kio"
        let mockDataController = MockDataController()
        viewModel.dataController = mockDataController
        
        apiManager.mockResult = nil
        viewModel.apiManger = apiManager
        // when
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            
            do {
                try await viewModel.runSearch()
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
    
    func testHomeViewModelPrepareKeywordErrorShouldShowError() {
        
        // given
        viewModel.isTyping = false
        viewModel.showAlert = true
        
        viewModel.prepareKeywordError()
        XCTAssertTrue(viewModel.shouldShowError)
    }
    
    func testHomeViewModelPrepareKeywordErrorAlert() {
        
        // given
        viewModel.prepareKeywordError()
        XCTAssertEqual(viewModel.errorTitle, "Keyword Too Short")
        XCTAssertEqual(viewModel.errorMessage, "Please enter a keyword with at least 3 characters.")
    }
    
    func testHomeViewModelPrepareAPIErrorShouldShowError() {
        
        // given
        viewModel.isTyping = false
        viewModel.showAlert = true
        
        viewModel.prepareAPIError()
        XCTAssertTrue(viewModel.shouldShowError)
    }
    
    func testHomeViewModelPrepareAPIErrorAlert() {
        
        // given
        viewModel.prepareAPIError()
        XCTAssertEqual(viewModel.errorTitle, "An error occurred")
        XCTAssertEqual(viewModel.errorMessage, "The request encountered an error. Please try again later.")
    }
    
    func generateRandomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString: String = (0..<length).map { _ in
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            return characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
        }.compactMap { String($0) }.joined()
        return randomString
    }
}
