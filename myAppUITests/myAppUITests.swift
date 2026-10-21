//
//  myAppUITests.swift
//  myAppUITests
//
//  Created by Konstantin on 24.07.2026.
//

import XCTest

final class myAppUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        
        XCTAssertTrue(
            authButton.waitForExistence(timeout: 5),
            "Кнопка авторизации не найдена"
        )
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(
            webView.waitForExistence(timeout: 10),
            "WebView авторизации не появился"
        )
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(
            loginTextField.waitForExistence(timeout: 10),
            "Поле e-mail не найдено"
        )
        loginTextField.tap()
        loginTextField.typeText("")
        
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(
            passwordTextField.waitForExistence(timeout: 10),
            "Поле пароля не найдено"
        )
        
        passwordTextField.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        passwordTextField.typeText("")
        
        webView.swipeUp()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(
            loginButton.waitForExistence(timeout: 10),
            "Кнопка Login не найдена"
        )
        loginButton.tap()
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(
            firstCell.waitForExistence(timeout: 20),
            "Лента фотографий не загрузилась после авторизации"
        )
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
    
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Первая ячейка не загрузилась")
        cell.swipeUp()
        
        sleep(2)
        
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Вторая ячейка не найдена")
        
        
        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
        
        XCTAssertTrue(app.staticTexts[""].exists)
        XCTAssertTrue(app.staticTexts[""].exists)
        
        app.buttons["logout button"].tap()
        sleep(2)
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Yes"].tap()
        
        sleep(2)
        
    }
}
