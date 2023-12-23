//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 20/12/23.
//

import Foundation
import CoreData

class HomeViewModel: ObservableObject {
    
    // var viewContext: NSManagedObjectContext
    @Published var cityList: [CityModel] = []
    @Published var searchText = ""
    
    
    /// Indicate search happens as user still  types in
    /// When `true` - Error messages will not show, for better UX
    @Published var isTyping: Bool = true
    
    @Published var showAlert = false
    @Published var shouldShowError: Bool = false
    
    @Published var errorTitle: String = ""
    @Published var errorMessage: String = ""
    
    var dataController: DataControllerProtocol = DataController.shared
    var apiManger: SearchAPIManagerProtocol = SearchAPIManager.shared
    
    
    /// Indicates whether a search operation should be performed based on the length of the searchText.
    /// - Returns: `true` if the length of `searchText` is greater than 2; otherwise, `false`.
    var shouldSearch: Bool {
        return self.searchText.count > 2
    }
    
    /// Indicates whether should show Past List if searchText is empty
    /// - Returns: `true` if the length of `searchText` is empty; otherwise, `false`.
    var shouldShowPastList: Bool {
        return self.searchText.count == 0
    }
    
    func generatePastList() {
        
        guard let savedCities = dataController.fetchLastViewed(limit: 10) else {
            cityList = []
            return
        }
        cityList = self.generateCities(from: savedCities)
    }
    
    func generateCities(from cities: [CityManagedObject]) -> [CityModel] {
        
        var cityList: [CityModel] = []
        for city in cities {
            cityList.append(CityModel(manageObj: city))
        }
        return cityList
    }
    
    @MainActor func searchAsType() async throws {
        
        // set to Typing mode
        isTyping = true
        if shouldShowPastList {
            self.generatePastList()
        }
        
        guard shouldSearch else {
            return
        }
                
        do {
            try await search()
        } catch let error {
            throw error
        }
    }
    
    @MainActor func runSearch() async throws {
        
        // When hit enter set Typing to false
        isTyping = false
        guard shouldSearch else {
            throw DataError.ShortKeyWord
        }
        
        do {
            try await search()
        } catch let error {
            throw error
        }
    }
    
    @MainActor func search() async throws {
        do {
            let cities = try await apiManger.search(by: self.searchText)
            self.cityList = self.getCities(from: cities)
        } catch let error {
            throw error
        }
    }
    
    private func getCities(from cities: [CityEntity]) -> [CityModel] {
        
        var cityList: [CityModel] = []
        for city in cities {
            cityList.append(CityModel(entity: city))
        }
        return cityList
    }
    
    func prepareKeywordError() {
        
        shouldShowError = showAlert && !isTyping
        self.errorTitle = AppCopy.getString(CopyStrings.short_keyword_error_title)
        self.errorMessage = AppCopy.getString(CopyStrings.short_keyword_error_description)
    }
    
    func prepareAPIError() {
        
        shouldShowError = showAlert && !isTyping
        print("Should Show error: \(shouldShowError)")
        self.errorTitle = AppCopy.getString(CopyStrings.api_error_title)
        self.errorMessage = AppCopy.getString(CopyStrings.api_error_message)
    }
}
