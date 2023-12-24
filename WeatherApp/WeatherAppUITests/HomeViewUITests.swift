//
//  HomeViewUITests.swift
//  WeatherAppUITests
//
//  Created by Dileepa Pathirana on 24/12/23.
//

import XCTest

final class HomeViewUITests: XCTestCase {

    let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    
    func testHomeViewTestSearch() {
        
        let searchField = app.navigationBars["Weather Apps"].searchFields["Search"]
        searchField.tap()
        
        let aKey = app.keys["A"]
        aKey.tap()
        
        let nKey = app.keys["n"]
        nKey.tap()
        
        let gKey = app.keys["g"]
        gKey.tap()
        
        let spaceKey = app.keys["space"]
        spaceKey.tap()
        
        let mKey = app.keys["m"]
        mKey.tap()
        
        let oKey = app.keys["o"]
        oKey.tap()
        
        app.buttons["Search"].tap()
        app.collectionViews.buttons["Ang Mo Kio_Singapore"].tap()
        
        let detailViewNavBar = app.navigationBars["Weather info"]
               
        XCTAssertTrue(detailViewNavBar.exists)
    }
    
    func testHomeViewShowKeyWordAlert() {
        
        let searchField = app.navigationBars["Weather Apps"].searchFields["Search"]
        searchField.tap()
        
        let aKey = app.keys["A"]
        aKey.tap()
        
        let nKey = app.keys["n"]
        nKey.tap()

        app.buttons["Search"].tap()
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.exists)
        
        let elements = alert.scrollViews.otherElements
        let alertTitle = elements.staticTexts["Keyword Too Short"]
        XCTAssertTrue(alertTitle.exists)
        
        alert.buttons["OK"].tap()
        
    }
    
    func testHomeViewNavigateToDetailView() {
        
        let searchField = app.navigationBars["Weather Apps"].searchFields["Search"]
        searchField.tap()
        
        let aKey = app.keys["A"]
        aKey.tap()
        
        let nKey = app.keys["n"]
        nKey.tap()
        
        let gKey = app.keys["g"]
        gKey.tap()
        
        let spaceKey = app.keys["space"]
        spaceKey.tap()
        
        let mKey = app.keys["m"]
        mKey.tap()
        
        let oKey = app.keys["o"]
        oKey.tap()
        
        app.buttons["Search"].tap()
        
        app.collectionViews.buttons["Ang Mo Kio_Singapore"].tap()
        
        sleep(5)
        
        let titleText = app.staticTexts["City_Name"]
        XCTAssertEqual(titleText.label, "Ang Mo Kio, Singapore")
        
        let weatherInfoText = app.staticTexts["City_Weather_info"]
        XCTAssertTrue(weatherInfoText.exists)
        
        let tempText = app.staticTexts["City_Temp"]
        XCTAssertTrue(tempText.exists)
        
        let humidityText = app.staticTexts["City_Humidity"]
        XCTAssertTrue(humidityText.exists)
        
    }
    

}
