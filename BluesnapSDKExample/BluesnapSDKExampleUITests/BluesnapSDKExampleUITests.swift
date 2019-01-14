//
//  BluesnapSDKExampleUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Oz on 26/03/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
import Foundation
import PassKit
import BluesnapSDK
@testable import BluesnapSDKIntegrationTests //TODO: make it work

class BluesnapSDKExampleUITests: XCTestCase {
    
//    let keyboardIsHidden = false
    private var app: XCUIApplication! //using Implicitly Unwrapped Optionals for initialization purpose

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /* -------------------------------- Returning shopper tests ---------------------------------------- */
    
    func testShortReturningShopperExistingCcFlow() {
        
        // no full billing, no shipping, no email, new CC
        
        let sdkRequest = prepareSdkRequest(fullBilling: false, withShipping: false, withEmail: false, amount: 20, currency: "USD")
        sdkRequest.priceDetails = nil
        
        gotoPaymentScreen(sdkRequest: sdkRequest, returningShopper: true, tapExistingCc: true)
        
        let _ = waitForExistingCcScreen()
        
        let payButton = checkPayButton(expectedPayText: "Pay $ 20.00")
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortReturningShopperExistingCcFlowWithShipping() {
        
        // no full billing, with shipping, no email, new CC
        
        let sdkRequest = prepareSdkRequest(fullBilling: false, withShipping: true, withEmail: false, amount: 20, currency: "USD")
        sdkRequest.priceDetails = nil
        
        gotoPaymentScreen(sdkRequest: sdkRequest, returningShopper: true, tapExistingCc: true)
        
        let existingCcHelper = waitForExistingCcScreen()

        // edit shipping to make sure we have the right country for tax calculation
        existingCcHelper.editShippingButton.tap()
        
        let shippingHelper = BSShippingScreenUITestHelper(app: app)
        shippingHelper.setFieldValues(shippingDetails: getDummyShippingDetails(countryCode: "US", stateCode: "MA"), sdkRequest: sdkRequest)
        shippingHelper.closeKeyboard()
        let editShippingPayButton = checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Done")
        editShippingPayButton.tap()

        let payButton = checkPayButton(expectedPayText: "Pay $ 21.00")
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortReturningShopperExistingCcFlowWithEdit() {
        
        // full billing, with shipping, no email, new CC
        
        let sdkRequest = prepareSdkRequest(fullBilling: true, withShipping: true, withEmail: false, amount: 20, currency: "USD")
        sdkRequest.priceDetails = nil
        
        gotoPaymentScreen(sdkRequest: sdkRequest, returningShopper: true, tapExistingCc: true)
        
        let existingCcHelper = waitForExistingCcScreen()
        
        existingCcHelper.editBillingButton.tap()
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        paymentHelper.setFieldValues(billingDetails: getDummyBillingDetails(), sdkRequest: sdkRequest)
        paymentHelper.closeKeyboard()
        let editBillingPayButton = checkPayButton(expectedPayText: "Done")
        editBillingPayButton.tap()
        
        existingCcHelper.editShippingButton.tap()

        let shippingHelper = BSShippingScreenUITestHelper(app: app)
        shippingHelper.setFieldValues(shippingDetails: getDummyShippingDetails(countryCode: "IL", stateCode: nil), sdkRequest: sdkRequest)
        shippingHelper.closeKeyboard()
        let editShippingPayButton = checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Done")
        editShippingPayButton.tap()
        
        let payButton = checkPayButton(expectedPayText: "Pay $ 20.00")
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }

    // full billing, with shipping, check "shipping same as billing"
    
    func testShortReturningShopperNewCcFlow() {
        
        // no full billing, no shipping, no email, new CC
        
        let sdkRequest = prepareSdkRequest(fullBilling: false, withShipping: false, withEmail: false, amount: 30, currency: "USD")
        sdkRequest.priceDetails = nil
        
        gotoPaymentScreen(sdkRequest: sdkRequest, returningShopper: true)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails(countryCode: "US"), ignoreCountry: true)
        
        let elementsQuery = app.scrollViews.otherElements
        let textField = elementsQuery.element(matching: .any, identifier: "Name")
        if textField.exists {
            textField.tap()
            app.keyboards.buttons["Done"].tap()
        }
        
        let payButton = checkPayButton(expectedPayText: "Pay $ 20.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }
    
    /* -------------------------------- New tests ---------------------------------------- */
    
    func testInputs() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: true, withShipping: false, withEmail: true, amount: 30, currency: "USD")
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
       
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check cc line visibility
        paymentHelper.checkNewCCLineVisibility()
        
        // change country to USA to have state and zip
        paymentHelper.setCountry(countryCode: "US")
        
        // delete CCN
        // TODO: add this once the issue is fixed
        
        // check trying to pay with empty fields
        paymentHelper.checkPayWithEmptyInputs(sdkRequest: sdkRequest)
        
        // check invalid cc line inputs
        // TODO: fix this.
//        paymentHelper.checkInvalidCCLineInputs()
        
        // check invalid billing inputs
        paymentHelper.checkInvalidInfoInputs()
        
        //app.buttons["PayButton"].tap()
                
        print("done")
    }

    func testFullBilling(){
        
    }

    
    /* -------------------------------- New shopper tests ---------------------------------------- */
    
    func testFlowFullBillingNoShippingNoEmail() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: true, withShipping: false, withEmail: false, amount: 30, currency: "USD")
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(expectedPayText: "Pay $ 30.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingNoEmail() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: true, withShipping: true, withEmail: false, amount: 30, currency: "USD")
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        let _ = checkPayButton(expectedPayText: "Pay $ 31.50")

        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        paymentHelper.closeKeyboard()
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(expectedPayText: "Pay $ 30.30")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(expectedPayText: "Shipping >")
        
        payButton.tap()
        waitForShippingScreen()
        
        let shippingPayButton = checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Pay $ 31.50")
        let shippingHelper = fillShippingDetails(app: app, sdkRequest: sdkRequest, shippingDetails: getDummyShippingDetails())
        let _ = checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Pay $ 30.30")
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingWithEmailNostate() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: true, withShipping: true, withEmail: true, amount: 20, currency: "USD")
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "IL"
        billingDetails.state = nil
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        let _ = checkPayButton(expectedPayText: "Pay $ 21.00")
        
        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: billingDetails)
        
        paymentHelper.closeKeyboard()
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(expectedPayText: "Pay $ 20.00")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(expectedPayText: "Shipping >")
        
        payButton.tap()
        waitForShippingScreen()
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GB"
        shippingDetails.state = nil

        let shippingPayButton = checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Pay $ 21.00")
        
        let shippingHelper = fillShippingDetails(app: app, sdkRequest: sdkRequest, shippingDetails: shippingDetails)
        let _ = checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Pay $ 20.00")
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingWithEmailNoZip() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: true, withShipping: true, withEmail: true, amount: 20, currency: "USD")
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "GH"
        billingDetails.state = nil
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: billingDetails)
        
        paymentHelper.closeKeyboard()
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(expectedPayText: "Pay $ 20.00")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(expectedPayText: "Shipping >")
        
        payButton.tap()
        waitForShippingScreen()
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GH"
        shippingDetails.state = nil
        let shippingHelper = fillShippingDetails(app: app, sdkRequest: sdkRequest, shippingDetails: shippingDetails)
        let shippingPayButton = checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Pay $ 20.00")
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowFullBillingNoShippingWithEmail() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: true, withShipping: false, withEmail: true, amount: 30, currency: "USD")
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(expectedPayText: "Pay $ 30.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowNoFullBillingNoShippingWithEmail() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: false, withShipping: false, withEmail: true, amount: 30, currency: "USD")
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(expectedPayText: "Pay $ 30.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowNoFullBillingNoShippingNoEmail() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: false, withShipping: false, withEmail: false, amount: 30, currency: "USD")
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(expectedPayText: "Pay $ 30.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortestFlowNoFullBillingNoShippingNoEmail() {
        
        let sdkRequest = prepareSdkRequest(fullBilling: false, withShipping: false, withEmail: false, amount: 30, currency: "USD")
        sdkRequest.priceDetails = nil
        
        gotoPaymentScreen(sdkRequest: sdkRequest)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        fillBillingDetails(paymentHelper: paymentHelper, sdkRequest: sdkRequest, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails(countryCode: "US"), ignoreCountry: true)
        
        paymentHelper.closeKeyboard()
        
        let payButton = checkPayButton(expectedPayText: "Pay $ 20.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }

    
    //------------------------------------ Helper functions ----------------------------
    
     
    private func checkResult(expectedSuccessText: String) {
        
        let successLabel = app.staticTexts["SuccessLabel"]
        waitForElementToExist(element: successLabel, waitTime: 300)
        let labelText: String = successLabel.label
        assert(labelText == expectedSuccessText)
    } 
    
    private func checkPayButton(expectedPayText: String) -> XCUIElement {
        
        return checkAPayButton(buttonId: "PayButton", expectedPayText: expectedPayText)
    }
    
    private func checkAPayButton(buttonId: String!, expectedPayText: String) -> XCUIElement {
        
        let payButton = app.buttons[buttonId]
        let payButtonText = payButton.label
        assert(expectedPayText == payButtonText)
        return payButton
    }
    
    private func getDummyBillingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSBillingAddressDetails {
        
        let billingDetails = BSBillingAddressDetails(email: "shevie@gmail.com", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : countryCode, state : stateCode)
        return billingDetails
    }
    
    private func getDummyShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {
        
        let shippingDetails = BSShippingAddressDetails(name: "Funny Brice", address: "77 Rambla street", city : "Barcelona", zip : "4815", country : countryCode, state : stateCode)
        return shippingDetails
    }
    
    private func getDummyEditBillingDetails(countryCode: String? = "US", stateCode: String? = "NY") -> BSBillingAddressDetails {
        
        let billingDetails = BSBillingAddressDetails(email: "test@sdk.com", name: "La Fleur", address: "555 Broadway street", city : "New York", zip : "3abc 324a", country : countryCode, state : stateCode)
        return billingDetails
    }
    
    private func getDummyEditShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {
        
        let shippingDetails = BSShippingAddressDetails(name: "Janet Weiss", address: "75 some street", city : "Denton", zip : "162342", country : countryCode, state : stateCode)
        return shippingDetails
    }
    
    private func prepareSdkRequest(fullBilling: Bool, withShipping: Bool, withEmail: Bool, amount: Double!, currency: String) -> BSSdkRequest {

        let taxAmount = amount * 0.05 // according to updateTax() in ViewController
        let priceDetails = BSPriceDetails(amount: amount, taxAmount: taxAmount, currency: currency)
        let sdkRequest = BSSdkRequest(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: {_ in }, updateTaxFunc: nil)
        return sdkRequest
    }
    
    private func fillBillingDetails(paymentHelper: BSPaymentScreenUITestHelper, sdkRequest: BSSdkRequest, ccn: String, exp: String, cvv: String, billingDetails: BSBillingAddressDetails, ignoreCountry: Bool? = false) {
        
        // fill CC values
        paymentHelper.setCcDetails(isOpen: true, ccn: ccn, exp: exp, cvv: cvv)
        
        // make sure fields are shown according to configuration
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest)
        
        // fill field values
        paymentHelper.setFieldValues(billingDetails: billingDetails, sdkRequest: sdkRequest, ignoreCountry: ignoreCountry)
        
        // check that the values are in correctly
        sdkRequest.shopperConfiguration.billingDetails = billingDetails
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest)
    }
    
    private func fillShippingDetails(app: XCUIApplication, sdkRequest: BSSdkRequest, shippingDetails: BSShippingAddressDetails) -> BSShippingScreenUITestHelper {
        
        let shippingHelper = BSShippingScreenUITestHelper(app:app)
        
        // make sure fields are shown according to configuration
        sdkRequest.shopperConfiguration.shippingDetails = BSShippingAddressDetails()
        // This fails because name field contains hint "John Doe" and the XCT returns it as the field value
        //paymentHelper.checkInputs(sdkRequest: sdkRequest)
        
        // fill field values
        shippingHelper.setFieldValues(shippingDetails: shippingDetails, sdkRequest: sdkRequest)
        
        // check that the values are in correctly
        sdkRequest.shopperConfiguration.shippingDetails = shippingDetails
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest)
        
        return shippingHelper
    }
    
    private func gotoPaymentScreen(sdkRequest: BSSdkRequest, returningShopper: Bool = false, tapExistingCc: Bool = false) {
        
        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)
        
        // set switches and amounts in merchant checkout screen
        setMerchantCheckoutScreen(app: app, sdkRequest: sdkRequest, returningShopper: returningShopper)
        
        // click "Checkout" button
        app.buttons["CheckoutButton"].tap()
        
        // wait for payment type screen to load
        
        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 120)
        
        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: true, expectedCC: true)
        
        if tapExistingCc {
            // click existing CC
            app.buttons["existingCc0"].tap()
            
        } else {
            // click New CC button
            app.buttons["CcButton"].tap()
        }
    }
    
    private func setMerchantCheckoutScreen(app: XCUIApplication, sdkRequest: BSSdkRequest, returningShopper: Bool = false) {
        
        // set new/returning shopper
        let returningShopperSwitch = app.switches["ReturningShopperSwitch"]
        waitForElementToExist(element: returningShopperSwitch, waitTime: 140)
        let returningShopperSwitchValue = (returningShopperSwitch.value as? String) ?? "0"
        if (returningShopperSwitchValue == "0" && returningShopper) || (returningShopperSwitchValue == "1" && !returningShopper) {
            returningShopperSwitch.tap()
            // wait for action to finish
            let coverView = app.otherElements.element(matching: .any, identifier: "CoverView")
            waitForEllementToDisappear(element: coverView, waitTime: 30)
        }
        
        // set with Shipping switch = on
        let withShippingSwitch = app.switches["WithShippingSwitch"]
        waitForElementToExist(element: withShippingSwitch, waitTime: 120)
        let withShippingSwitchValue = (withShippingSwitch.value as? String) ?? "0"
        if (withShippingSwitchValue == "0" && sdkRequest.shopperConfiguration.withShipping) || (withShippingSwitchValue == "1" && !sdkRequest.shopperConfiguration.withShipping) {
            withShippingSwitch.tap()
        }
        
        // set full billing switch = on
        let fullBillingSwitch = app.switches["FullBillingSwitch"]
        let fullBillingSwitchValue = (fullBillingSwitch.value as? String) ?? "0"
        if (fullBillingSwitchValue == "0" && sdkRequest.shopperConfiguration.fullBilling) || (fullBillingSwitchValue == "1" && !sdkRequest.shopperConfiguration.fullBilling) {
            fullBillingSwitch.tap()
        }
        
        // set with Email switch = on
        let withEmailSwitch = app.switches["WithEmailSwitch"]
        let withEmailSwitchValue = (withEmailSwitch.value as? String) ?? "0"
        if (withEmailSwitchValue == "0" && sdkRequest.shopperConfiguration.withEmail) || (withEmailSwitchValue == "1" && !sdkRequest.shopperConfiguration.withEmail) {
            withEmailSwitch.tap()
        }
        
        if let priceDetails = sdkRequest.priceDetails {
            
            // set amount text field value
            let amount = "\(priceDetails.amount ?? 0)"
            let amountField : XCUIElement = app.textFields["AmountField"]
            amountField.tap()
            amountField.doubleTap()
            amountField.typeText(amount)
        }
        
    }
    
    private func waitForExistingCcScreen() -> BSExistingCcScreenUITestHelper {
        
        let existingCcHelper = BSExistingCcScreenUITestHelper(app:app)
        waitForElementToExist(element: existingCcHelper.billingNameLabel, waitTime: 60)
        return existingCcHelper
    }
    
    private func waitForPaymentScreen() {

        let payButton = app.buttons["PayButton"]
        waitForElementToExist(element: payButton, waitTime: 60)
    }
    
    private func waitForShippingScreen() {

        let payButton = app.buttons["ShippingPayButton"]
        waitForElementToExist(element: payButton, waitTime: 60)
    }
    
    private func waitForElementToExist(element: XCUIElement, waitTime: TimeInterval) {

        let exists = NSPredicate(format: "exists == 1")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
//        waitForExpectations(timeout: waitTime, handler: { error in
//            NSLog("Finished waiting")
//        })
    }
    
    private func waitForEllementToDisappear(element: XCUIElement, waitTime: TimeInterval) {

        let exists = NSPredicate(format: "exists == 0")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
    }
}

//extension XCTestCase {
//    
//    func wait(for duration: TimeInterval) {
//        let waitExpectation = expectation(description: "Waiting")
//        
//        let when = DispatchTime.now() + duration
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            waitExpectation.fulfill()
//        }
//        
//        // We use a buffer here to avoid flakiness with Timer on CI
//        waitForExpectations(timeout: duration + 0.5)
//    }
//}
