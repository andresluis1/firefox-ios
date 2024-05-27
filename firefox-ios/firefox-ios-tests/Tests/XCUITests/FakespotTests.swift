// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/
import XCTest

class FakespotTests: IphoneOnlyTestCase {
    // https://testrail.stage.mozaws.net/index.php?/cases/view/2307128
    func testFakespotAvailable() {
        if skipPlatform { return }
        reachReviewChecker()
        mozWaitForElementToExist(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle])
        XCTAssertEqual(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle].label, "Review Checker")

        // Close the popover
        app.otherElements.buttons[AccessibilityIdentifiers.Shopping.sheetCloseButton].tap()
        mozWaitForElementToNotExist(app.otherElements[AccessibilityIdentifiers.Shopping.sheetHeaderTitle])
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2358865
    // Smoketest
    func testReviewQualityCheckBottomSheetUI() {
        if skipPlatform { return }
        reachReviewChecker()
        mozWaitForElementToExist(app.buttons[AccessibilityIdentifiers.Shopping.OptInCard.mainButton])
        app.buttons[AccessibilityIdentifiers.Shopping.OptInCard.mainButton].tap()

        // Check the content of the Review quality check sheet
        mozWaitForElementToExist(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle])
        XCTAssertEqual(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle].label, "Review Checker")
        XCTAssertEqual(app.buttons[AccessibilityIdentifiers.Shopping.sheetCloseButton].label, "Close Review Checker")
        if app.staticTexts["How reliable are these reviews?"].exists {
            XCTAssertEqual(app.staticTexts[AccessibilityIdentifiers.Shopping.ReliabilityCard.title].firstMatch.label,
                           "How reliable are these reviews?")
            XCTAssertTrue(app.staticTexts["Adjusted rating"].exists)
            validateHighlightsSection()
        } else {
            XCTAssertTrue(app.staticTexts["No info about these reviews yet"].exists)
            XCTAssertTrue(app.buttons["Check Review Quality"].exists)
        }
        mozWaitForElementToExist(app.staticTexts[AccessibilityIdentifiers.Shopping.ReviewQualityCard.title])
        XCTAssertEqual(app.staticTexts[AccessibilityIdentifiers.Shopping.ReviewQualityCard.title].label,
                       "How we determine review quality")
        XCTAssertEqual(app.staticTexts[AccessibilityIdentifiers.Shopping.SettingsCard.title].label, "Settings")
        XCTAssertTrue(app.staticTexts["Review Checker is powered by Fakespot by Mozilla"].exists)
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2358902
    // Smoketest
    func testPriceTagIconAvailableOnlyOnDetailPage() {
        if skipPlatform { return }
        // Search for a product but do not open the product detail page
        loadWebsiteAndPerformSearch()

        // The Price tag icon is NOT displayed on the address bar of the search result page
        mozWaitForElementToNotExist(app.buttons[AccessibilityIdentifiers.Toolbar.shoppingButton])
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2358904
    // Smoketest
    func testPriceTagNotDisplayedInPrivateMode() {
        if skipPlatform { return }
        // Open a product detail page using a private tab and check the address bar
        loadWebsiteInPrivateMode()

        // The Price tag icon is NOT displayed
        mozWaitForElementToNotExist(app.buttons[AccessibilityIdentifiers.Toolbar.shoppingButton])
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2358924
    // Smoketest
    func testAcceptTheRejectedOptInNotification() {
        if skipPlatform { return }
        reachReviewChecker()
        mozWaitForElementToExist(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle])
        XCTAssertEqual(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle].label, "Review Checker")

        // Reject the Opt-in notification
        app.otherElements.buttons[AccessibilityIdentifiers.Shopping.sheetCloseButton].tap()
        // The sheet is dismissed and the user remains opted-out
        mozWaitForElementToNotExist(app.otherElements[AccessibilityIdentifiers.Shopping.sheetHeaderTitle])
        mozWaitForElementToExist(app.buttons[AccessibilityIdentifiers.Toolbar.shoppingButton])
        // Tap again the Price tag icon
        app.buttons[AccessibilityIdentifiers.Toolbar.shoppingButton].tap()
        // The contextual onboarding screen is displayed
        mozWaitForElementToExist(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle])
        XCTAssertEqual(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle].label, "Review Checker")
        // Tap the "Yes, Try it" button
        mozWaitForElementToExist(app.buttons[AccessibilityIdentifiers.Shopping.OptInCard.mainButton])
        app.buttons[AccessibilityIdentifiers.Shopping.OptInCard.mainButton].tap()
        // The sheet is populated with product feedback data
        mozWaitForElementToExist(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle])
        XCTAssertEqual(app.staticTexts[AccessibilityIdentifiers.Shopping.sheetHeaderTitle].label, "Review Checker")
        XCTAssertEqual(app.buttons[AccessibilityIdentifiers.Shopping.sheetCloseButton].label, "Close Review Checker")
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2358901
    func testPriceTagNotDisplayedOnSitesNotIntegratedFakespot() {
        if skipPlatform { return }
        // Navigate to ebay.com
        navigator.openURL("https://www.ebay.com")
        waitUntilPageLoad()
        // The price tag icon is not displayed
        mozWaitForElementToNotExist(app.buttons[AccessibilityIdentifiers.Toolbar.shoppingButton])
        // Open a product detail page and check the address bar
        let searchField = app.webViews["contentView"].webViews.textFields["Search for anything"]
        mozWaitForElementToExist(searchField)
        searchField.tap()
        searchField.typeText("Shoe")
        mozWaitForElementToExist(app.webViews["contentView"].webViews.buttons["Search"])
        app.webViews["contentView"].webViews.buttons["Search"].tap()
        waitUntilPageLoad()
        app.webViews["contentView"].links.element(boundBy: 7).tap()
        waitUntilPageLoad()
        // The price tag icon is not displayed
        mozWaitForElementToNotExist(app.buttons[AccessibilityIdentifiers.Toolbar.shoppingButton])
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2358863
    // Smoketest
    func testSettingsSectionUI() {
        if skipPlatform { return }
        // Navigate to a product detail page
        reachReviewChecker()
        mozWaitForElementToExist(app.buttons[AccessibilityIdentifiers.Shopping.OptInCard.mainButton])
        app.buttons[AccessibilityIdentifiers.Shopping.OptInCard.mainButton].tap()
        // Check the 'Settings' collapsible section
        let settingsSection = app.staticTexts[AccessibilityIdentifiers.Shopping.SettingsCard.title]
        let expandButton = app.buttons[AccessibilityIdentifiers.Shopping.SettingsCard.expandButton]
        mozWaitForElementToExist(settingsSection)
        mozWaitForElementToExist(expandButton)
        // Tap to open the section
        expandButton.tap()
        mozWaitForElementToExist(settingsSection)
        // Validate expanded settings section
        validateExpandedSettingsSection()
        // Switch the theme from light to dark mode
        switchThemeToDarkOrLight()
        mozWaitForElementToExist(settingsSection)
        // Validate expanded settings section
        validateExpandedSettingsSection()
        // Switch the theme from light to dark mode
        switchThemeToDarkOrLight()
        // Validate expanded settings section
        validateExpandedSettingsSection()
    }

    private func switchThemeToDarkOrLight() {
        mozWaitForElementToExist(app.buttons[AccessibilityIdentifiers.Toolbar.settingsMenuButton])
        navigator.nowAt(BrowserTab)
        navigator.goto(SettingsScreen)
        navigator.goto(DisplaySettings)
        mozWaitForElementToExist(app.switches["SystemThemeSwitchValue"])
        navigator.performAction(Action.SystemThemeSwitch)
        if app.switches["SystemThemeSwitchValue"].value! as! String == "0" {
            mozWaitForElementToExist(app.cells.staticTexts["Dark"])
            if app.cells.element(boundBy: 3).isSelected {
                app.cells.staticTexts["Dark"].tap()
            } else {
                app.cells.staticTexts["Light"].tap()
            }
        }
        app.buttons["Settings"].tap()
        navigator.nowAt(SettingsScreen)
        waitForExistence(app.buttons["Done"])
        app.buttons["Done"].tap()
        app.buttons[AccessibilityIdentifiers.Toolbar.shoppingButton].tap()
        scrollToElement(app.staticTexts[AccessibilityIdentifiers.Shopping.SettingsCard.title])
    }

    private func validateExpandedSettingsSection() {
        let shoppingIdentifier = AccessibilityIdentifiers.Shopping.SettingsCard.self
        XCTAssertEqual(app.buttons[shoppingIdentifier.expandButton].label, "Collapse Settings Card")
        XCTAssertEqual(app.buttons[shoppingIdentifier.turnOffButton].label, "Turn Off Review Checker")
        app.otherElements.buttons[AccessibilityIdentifiers.Shopping.sheetCloseButton].tap()
    }

    private func validateHighlightsSection() {
        if app.staticTexts[AccessibilityIdentifiers.Shopping.HighlightsCard.title].exists {
            let highlights = AccessibilityIdentifiers.Shopping.HighlightsCard.self
            XCTAssertEqual(app.staticTexts[highlights.title].label, "Highlights from recent reviews")
            if app.staticTexts["Show More"].exists {
                app.staticTexts["Show More"].tap()
                let isVisible = true
                switch isVisible {
                case app.staticTexts[highlights.groupPriceTitle].exists:
                    XCTAssertEqual(app.staticTexts[highlights.groupPriceTitle].label, "Price")
                case app.staticTexts[highlights.groupQualityTitle].exists:
                    XCTAssertEqual(app.staticTexts[highlights.groupQualityTitle].label, "Quality")
                case app.staticTexts[highlights.groupShippingTitle].exists:
                    XCTAssertEqual(app.staticTexts[highlights.groupQualityTitle].label, "Shipping")
                case app.staticTexts[highlights.groupPackagingTitle].exists:
                    XCTAssertEqual(app.staticTexts[highlights.groupQualityTitle].label, "Packaging")
                case app.staticTexts[highlights.groupCompetitivenessTitle].exists:
                    XCTAssertEqual(app.staticTexts[highlights.groupQualityTitle].label, "Competitiveness")
                default:
                    break
                }
                scrollToElement(app.staticTexts["Show Less"])
                app.staticTexts["Show Less"].tap()
            } else {
                XCTAssertTrue(app.staticTexts["Show Less"].exists)
                scrollToElement(app.staticTexts["Review Checker is powered by Fakespot by Mozilla"])
            }
        }
    }

    private func reachReviewChecker() {
        loadWebsiteAndPerformSearch()
        app.webViews["contentView"].firstMatch.images.firstMatch.tap()
        waitUntilPageLoad()

        // Retry loading the page if page is not loading
        while app.webViews.staticTexts["Enter the characters you see below"].exists {
            app.buttons["Reload page"].tap()
            waitUntilPageLoad()
        }
        // Tap the shopping cart icon
        app.buttons[AccessibilityIdentifiers.Toolbar.shoppingButton].tap()
    }

    private func loadWebsiteAndPerformSearch() {
        navigator.openURL("https://www.amazon.com")
        waitUntilPageLoad()
        let website = app.webViews["contentView"].firstMatch

        // Search for and open a shoe listing
        let searchAmazon = website.textFields["Search Amazon"]
        if !searchAmazon.exists {
            navigator.openURL("https://www.amazon.com")
            waitUntilPageLoad()
        }
        mozWaitForElementToExist(searchAmazon)
        XCTAssert(searchAmazon.isEnabled)
        searchAmazon.tap()
        if !app.keyboards.element.isHittable {
            searchAmazon.tap()
        }
        searchAmazon.typeText("Shoe")
        website.buttons["Go"].tap()
        waitUntilPageLoad()
        while website.links.elementContainingText("Sorry! Something went wrong on our end.").exists {
            app.buttons["Reload page"].tap()
            waitUntilPageLoad()
        }
    }

    private func loadWebsiteInPrivateMode() {
        navigator.nowAt(NewTabScreen)
        navigator.toggleOn(userState.isPrivate, withAction: Action.TogglePrivateMode)
        navigator.performAction(Action.OpenNewTabFromTabTray)
        navigator.openURL("https://www.amazon.com")
        waitUntilPageLoad()
        let website = app.webViews["contentView"].firstMatch
        let searchAmazon = website.textFields["Search Amazon"]
        while !searchAmazon.exists {
            app.buttons["Reload page"].tap()
            waitUntilPageLoad()
        }
        mozWaitForElementToExist(searchAmazon)
        searchAmazon.tap()
        if !app.keyboards.element.isHittable {
            searchAmazon.tap()
        }
        searchAmazon.typeText("Shoe")
        website.buttons["Go"].tap()
        waitUntilPageLoad()
        app.webViews["contentView"].firstMatch.images.firstMatch.tap()
        waitUntilPageLoad()
    }
}