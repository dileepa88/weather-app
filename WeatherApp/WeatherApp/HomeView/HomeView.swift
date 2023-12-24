//
//  ContentView.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 19/12/23.
//

import SwiftUI
import CoreData

struct HomeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            List(viewModel.cityList, id: \.self) { item in
                NavigationLink(value: item) {
                    Text("\(item.name), \(item.country)").accessibilityLabel("\(item.name)_\(item.country)")
                }
            }
            .navigationDestination(for: CityModel.self, destination: { item in
                WeatherDetailView(city: item)
            })
            .onAppear {
                if viewModel.shouldShowPastList {
                    self.viewModel.generatePastList()
                }
            }.navigationTitle("Weather App")

        }
        .searchable(text: $viewModel.searchText)
        .accessibilityLabel("YourSearchBarAccessibilityIdentifier")
        .disableAutocorrection(true)
        .onChange(of: viewModel.searchText) { value in
            self.searchAsTyping()
        }
        .onSubmit(of: .search) {
            self.search()
        }.alert(isPresented: $viewModel.shouldShowError) {
            Alert(
                title: Text(viewModel.errorTitle),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text(AppCopy.getString(CopyStrings.alert_button_ok))) {
                    viewModel.showAlert = false
                }
            )
        }

        /*NavigationView {

            NavigationStack {
                
                List(viewModel.cityList, id: \.self) { item in
                    NavigationLink(value: item) {
                        Text("\(item.name), \(item.country)")
                    }
                }
                .navigationDestination(for: CityModel.self, destination: { item in
                    WeatherDetailView(city: item)
                })
                .onAppear {
                    if viewModel.shouldShowPastList {
                        self.viewModel.generatePastList()
                    }
                }
            }
            .searchable(text: $viewModel.searchText)
            .disableAutocorrection(true)
            .onChange(of: viewModel.searchText) { value in
                self.searchAsTyping()
            }
            .onSubmit(of: .search) {
                self.search()
            }.alert(isPresented: $viewModel.shouldShowError) {
                Alert(
                    title: Text(viewModel.errorTitle),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text(AppCopy.getString(CopyStrings.alert_button_ok))) {
                        viewModel.showAlert = false
                    }
                )
            }
        }*/
    }
    
    private func search() {
        Task {
            do {
                try await self.viewModel.runSearch()
            } catch let error {
                self.handleError(error)
            }
        }
    }
    
    private func searchAsTyping() {
        Task {
            do {
                try await self.viewModel.searchAsType()
            } catch let error {
                self.handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        
        self.viewModel.showAlert = true
        switch error {
        case DataError.BadRequest:
            self.viewModel.prepareAPIError()
            print("Invalid URL")
        case DataError.ShortKeyWord:
            self.viewModel.prepareKeywordError()
            print("Keyword too short")
        case DataError.BadData:
            self.viewModel.prepareAPIError()
            print("Bad Data")
        default:
            self.viewModel.prepareAPIError()
            print("other errror")
        }
    }
   
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    HomeView().environment(\.managedObjectContext, DataController.preview.container.viewContext)
}
