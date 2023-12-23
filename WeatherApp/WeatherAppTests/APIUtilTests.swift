//
//  APIUtilTests.swift
//  WeatherAppTests
//
//  Created by Dileepa Pathirana on 24/12/23.
//

import XCTest
import Foundation
@testable import WeatherApp

final class APIUtilTests: XCTestCase {
    
    class MockURLSession: URLSessionProtocol {
        var mockData: Data?
        var mockResponse: URLResponse?
        var mockError: Error?
        
        func data(form request: URLRequest) async throws -> (Data, URLResponse) {
            
            if let error = mockError {
                throw error
            }
            
            guard let data = mockData, let response = mockResponse else {
                throw URLError(.badServerResponse)
            }
            
            return (data, response)
        }
    }
    
    var apiUtil: APIUtilProtocol!

    override func setUpWithError() throws {
        apiUtil = APIUtil()
    }

    override func tearDownWithError() throws {
        apiUtil = nil
    }
    
    func readJSONFromFile(fileName: String) throws -> Data {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "json") else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
        }
        let str = try String(contentsOfFile: filePath, encoding: .utf8)
        let jsonString = str
        let jsonData = jsonString.data(using: .utf8)!
        return jsonData
    }
    
    func testAPIUtilFetchSuccessSearch() {
        
        let mockUrlSession: MockURLSession = MockURLSession()
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let apiRequest = Constants.APIRequest.searchCity(query: "")

        do {
            let data = try readJSONFromFile(fileName: "MockSearchAMK")
            mockUrlSession.mockData = data
        } catch {
            XCTFail()
        }
        
        mockUrlSession.mockError = nil
        mockUrlSession.mockResponse = expectedResponse
        apiUtil.urlSession = mockUrlSession
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                let cityData: CitySearchData? = try await apiUtil.fetch(for: apiRequest)
                XCTAssertNotNil(cityData)
                XCTAssertNotNil(cityData?.searchApi)
                XCTAssertNotNil(cityData?.searchApi.result)
                XCTAssertEqual(cityData?.searchApi.result.count, 1)
                XCTAssertEqual(cityData?.searchApi.result.first?.areaName ?? "", "Ang Mo Kio")
                
            } catch {
                XCTFail()
            }
            
            await MainActor.run {
               expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAPIUtilFetchSuccessSearch2() {
        
        let mockUrlSession: MockURLSession = MockURLSession()
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let apiRequest = Constants.APIRequest.searchCity(query: "")

        do {
            let data = try readJSONFromFile(fileName: "MockSearchLondon")
            mockUrlSession.mockData = data
        } catch {
            XCTFail()
        }
        
        mockUrlSession.mockError = nil
        mockUrlSession.mockResponse = expectedResponse
        apiUtil.urlSession = mockUrlSession
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                let cityData: CitySearchData? = try await apiUtil.fetch(for: apiRequest)
                XCTAssertNotNil(cityData)
                XCTAssertNotNil(cityData?.searchApi)
                XCTAssertNotNil(cityData?.searchApi.result)
                XCTAssertEqual(cityData?.searchApi.result.count, 2)
                XCTAssertEqual(cityData?.searchApi.result.first?.areaName ?? "", "London")
                XCTAssertEqual(cityData?.searchApi.result.first?.country ?? "", "United Kingdom")
            } catch {
                XCTFail()
            }
            
            await MainActor.run {
               expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAPIUtilFetchFailBadData() {
        
        let mockUrlSession: MockURLSession = MockURLSession()
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let apiRequest = Constants.APIRequest.searchCity(query: "")

        do {
            let data = try readJSONFromFile(fileName: "MockSearchAMKBadData")
            mockUrlSession.mockData = data
        } catch {
            XCTFail()
        }
        
        mockUrlSession.mockError = nil
        mockUrlSession.mockResponse = expectedResponse
        apiUtil.urlSession = mockUrlSession
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                let _: CitySearchData? = try await apiUtil.fetch(for: apiRequest)
                
            } catch let error as DataError {
                XCTAssertEqual(error, DataError.BadData)
            } catch {
                XCTFail()
            }
            
            await MainActor.run {
               expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAPIUtilFetchErrorResponse() {
        
        let mockUrlSession: MockURLSession = MockURLSession()
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil)!
        let apiRequest = Constants.APIRequest.weatherDetail(query: "")

        do {
            let data = try readJSONFromFile(fileName: "MockSearchAMKBadData")
            mockUrlSession.mockData = data
        } catch {
            XCTFail()
        }
        
        mockUrlSession.mockError = nil
        mockUrlSession.mockResponse = expectedResponse
        apiUtil.urlSession = mockUrlSession
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                let _: CitySearchData? = try await apiUtil.fetch(for: apiRequest)
                
            } catch let error as URLError {
                XCTAssertEqual(error, URLError(.badServerResponse))
            } catch {
                XCTFail()
            }
            
            await MainActor.run {
               expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAPIUtilFetchSuccessWeatherDetail() {
        
        let mockUrlSession: MockURLSession = MockURLSession()
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let apiRequest = Constants.APIRequest.weatherDetail(query: "")

        do {
            let data = try readJSONFromFile(fileName: "WeatherDetailMock")
            mockUrlSession.mockData = data
        } catch {
            XCTFail()
        }
        
        mockUrlSession.mockError = nil
        mockUrlSession.mockResponse = expectedResponse
        apiUtil.urlSession = mockUrlSession
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                let weatherData: WeatherDetailData? = try await apiUtil.fetch(for: apiRequest)
                XCTAssertNotNil(weatherData)
                XCTAssertNotNil(weatherData?.data)
                XCTAssertNotNil(weatherData?.data.currentCondition)
                XCTAssertEqual(weatherData?.data.currentCondition.count, 1)
                XCTAssertEqual(weatherData?.data.currentCondition.first?.tempC, "26")
                XCTAssertEqual(weatherData?.data.currentCondition.first?.humidity, "94")
                XCTAssertEqual(weatherData?.data.currentCondition.first?.weatherDesc, "Partly cloudy")
                XCTAssertEqual(weatherData?.data.currentCondition.first?.weatherIconUrl, "https://cdn.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0004_black_low_cloud.png")
            } catch {
                XCTFail()
            }
            
            await MainActor.run {
               expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAPIUtilFetchFaultRequest() {
        
        let mockUrlSession: MockURLSession = MockURLSession()
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil)!

        do {
            let data = try readJSONFromFile(fileName: "MockSearchAMKBadData")
            mockUrlSession.mockData = data
        } catch {
            XCTFail()
        }
        
        mockUrlSession.mockError = nil
        mockUrlSession.mockResponse = expectedResponse
        apiUtil.urlSession = mockUrlSession
        
        let expectation = XCTestExpectation(description: "Search Expectation")
        
        Task {
            do {
                let _: CitySearchData? = try await apiUtil.fetch(for: nil)
                
            } catch let error as DataError {
                XCTAssertEqual(error, DataError.BadRequest)
            } catch {
                XCTFail()
            }
            
            await MainActor.run {
               expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

}
