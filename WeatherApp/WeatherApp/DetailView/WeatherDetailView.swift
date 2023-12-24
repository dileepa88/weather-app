//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 20/12/23.
//

import Foundation
import SwiftUI
import CoreData

struct WeatherDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var viewModel: WeatherDetailViewModel
    
    init(city: CityModel) {
        viewModel = WeatherDetailViewModel(currentCity: city)
    }
    
    var body: some View {
        
        VStack(spacing: 35) {
            
            Text("\(viewModel.currentCity.name), \(viewModel.currentCity.country)")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("City_Name")            
            
            AsyncImage(url: URL.init(string: viewModel.weatherDetail?.weatherIconUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.gray)
            }.frame(width: 100, height: 100)
            
            VStack(spacing: 5) {
                Text(viewModel.weatherDetail?.weatherDesc ?? "")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .accessibilityIdentifier("City_Weather_info")
                
                Text("Temperature: " + (viewModel.weatherDetail?.tempC ?? "") + "C")
                    .font(.system(size: 16))
                    .accessibilityIdentifier("City_Temp")
                
                Text("Humidity: " + (viewModel.weatherDetail?.humidity ?? ""))
                    .font(.system(size: 16))
                    .accessibilityIdentifier("City_Humidity")
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Weather info")
        .task {
            await getDetails()
        }
    }
    
    func getDetails() async {
        
       self.viewModel.saveViewedCity(self.viewModel.currentCity)
        do {
            try await viewModel.getWeatherDetails(for: viewModel.currentCity)
        } catch let error {
            self.handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        
        switch error {
        case DataError.BadRequest:
            print("Invalid URL")
        case DataError.ShortKeyWord:
            print("Keyword too short")
        case DataError.BadData:
            print("Bad Data")
        default:
            print("other error")
        }
    }
}

