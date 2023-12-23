//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 19/12/23.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    
    let persistenceController = DataController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
