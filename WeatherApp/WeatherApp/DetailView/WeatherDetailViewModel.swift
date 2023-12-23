//
//  WeatherDetailViewModel.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 20/12/23.
//

import Foundation
import CoreData

class WeatherDetailViewModel: ObservableObject {
    
    @Published var weatherDetail: WeatherDetailModel?
    @Published var currentCity: CityModel
    
    var dataController: ExtendedDataControllerProtocol = DataController.shared
    
    var apiManger: WeatherAPIManagerProtocol = WeatherDetailAPIManager.shared
    
    init(currentCity: CityModel) {
        self.currentCity = currentCity
    }
    
    @MainActor func getWeatherDetails(for city: CityModel) async throws {
        
        do {
            guard let weatherEntity = try await apiManger.getDetail(cityName: city.fullName) else { throw DataError.BadData }
            weatherDetail = WeatherDetailModel(entity: weatherEntity)
        } catch let error {
            throw error
        }
    }
    
    func saveViewedCity(_ city: CityModel) {
        
        let controller = dataController
        if let savedCity = controller.retrieve(city: city, viewContext: controller.container.viewContext) {
            controller.updateLastViewedTime(city: savedCity, date: Date(), viewContext: controller.container.viewContext)
        } else {
            let cityModel = DataController.shared.addCity(model: city, viewContext: controller.container.viewContext)
            controller.updateLastViewedTime(city: cityModel, date: Date(), viewContext: controller.container.viewContext)
        }
    }
    
}
