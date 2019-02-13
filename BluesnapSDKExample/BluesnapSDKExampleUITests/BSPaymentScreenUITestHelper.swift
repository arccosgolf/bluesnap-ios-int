//
//  BSPaymentScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 07/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK
import PassKit

class BSPaymentScreenUITestHelper: BSCreditCardScreenUITestHelperBase {
    
    var ccLineInput : XCUIElement!
    var existingCcLineInput : XCUIElement!
    var emailInput : XCUIElement!
    var waitForElementToExistFunc : (XCUIElement, TimeInterval)->Void;
    var waitForElementToDisappear : (XCUIElement, TimeInterval)->Void;

    init(app: XCUIApplication!, waitForElementToExistFunc : @escaping (XCUIElement, TimeInterval)->Void, waitForElementToDisappear : @escaping (XCUIElement, TimeInterval)->Void) {
        let elementsQuery = app.scrollViews.otherElements
        ccLineInput = elementsQuery.element(matching: .any, identifier: "CCN")
        existingCcLineInput = elementsQuery.element(matching: .any, identifier: "ExistingCCN")
        emailInput = elementsQuery.element(matching: .any, identifier: "Email")
        
        self.waitForElementToExistFunc = waitForElementToExistFunc
        self.waitForElementToDisappear = waitForElementToDisappear
        super.init(app: app)
        nameInput = elementsQuery.element(matching: .any, identifier: "Name")
        zipInput = elementsQuery.element(matching: .any, identifier: "Zip")
        cityInput = elementsQuery.element(matching: .any, identifier: "City")
        streetInput = elementsQuery.element(matching: .any, identifier: "Street")
        stateInput = elementsQuery.element(matching: .any, identifier: "State")
    }
    
    func getCcInputFieldElement() -> XCUIElement {
        return ccLineInput.textFields["CcTextField"]
    }
    
    func getLast4digitsLabelElement() -> XCUIElement {
        return ccLineInput.staticTexts["last4digitsLabel"]
    }
    
    func getExpInputFieldElement() -> XCUIElement {
        return ccLineInput.textFields["ExpTextField"]
    }
    
    func getCvvInputFieldElement() -> XCUIElement {
        return ccLineInput.textFields["CvvTextField"]
    }
    
    func getCcInputErrorLabelElement() -> XCUIElement {
        return ccLineInput.staticTexts["ErrorLabel"]
    }
    
    func getExpInputErrorLabelElement() -> XCUIElement {
        return ccLineInput.staticTexts["ExpErrorLabel"]
    }
    
    func getCvvInputErrorLabelElement() -> XCUIElement {
        return ccLineInput.staticTexts["CvvErrorLabel"]
    }
    
    func getManuButton() -> XCUIElement {
        return app.buttons["MenuButton"]
    }
    
    
    /**
     This test verifies the visibility of the cc line,
     and that they show the correct content.
     It also verifies that the invalid error messages are not displayed. "1234 5678 9012 3456"
     */
    func checkNewCCLineVisibility() {
        XCTAssertTrue(ccLineInput.exists, "CC line is not displayed")
        
        checkCcnComponentState(ccnShouldBeOpen: true, ccn: "1234 5678 9012 3456", last4digits: "", exp: "", cvv: "")
    }
    
    func checkNewCCLineVisibilityAfterEnteringCCN() {
        //enter a valid cc number to make exp date and cvv
        setCcNumber(ccn: BSUITestUtils.getValidVisaCreditCardNumber())

        checkCcnComponentState(ccnShouldBeOpen: false, ccn: "", last4digits: "1111", exp: "MM/YY", cvv: "CVV")
    }
    
    
    // check CCN component state
    func checkCcnComponentState(ccnShouldBeOpen: Bool, ccn: String, last4digits: String, exp: String, cvv: String) {
        
        if ccnShouldBeOpen {
            checkCCLineInput(input: getCcInputFieldElement(), expectedExists: true, expectedValue: ccn, invalidError: getCcInputErrorLabelElement())
            waitForElementToDisappear(getExpInputFieldElement(), 3)
            checkCCLineInput(input: getExpInputFieldElement(), expectedExists: false, expectedValue: "", invalidError: getExpInputErrorLabelElement())
            checkCCLineInput(input: getCvvInputFieldElement(), expectedExists: false, expectedValue: "", invalidError: getCvvInputErrorLabelElement())
        } else {
            waitForElementToExistFunc(getExpInputFieldElement(), 3)
            checkCCLineInput(input: getExpInputFieldElement(), expectedExists: true, expectedValue: exp, invalidError: getExpInputErrorLabelElement())
            checkCCLineInput(input: getCvvInputFieldElement(), expectedExists: true, expectedValue: cvv, invalidError: getCvvInputErrorLabelElement())
            checkCCLineInput(input: getLast4digitsLabelElement(), expectedExists: true, expectedValue: last4digits, invalidError: getCcInputErrorLabelElement(), isLabel: true)
        }
        
    }
    
    func checkExistingCCLineVisibility(expectedLastFourDigits: String, expectedExpDate: String) {        
        // get the cc line component's labels
        let lastFourDigitsLabel = existingCcLineInput.staticTexts["Last4DigitsLabel"]
        let expDateLabel = existingCcLineInput.staticTexts["ExpirationLabel"]
        
        // verify that the labels match the expected values
        let lastFourDigitsLabelText: String = lastFourDigitsLabel.label
        XCTAssertTrue(lastFourDigitsLabelText == expectedLastFourDigits, "Last Four Digits label expected value: \(expectedLastFourDigits), actual value: \(lastFourDigitsLabelText)")
        
        let expDateLabelText: String = expDateLabel.label
        XCTAssertTrue(expDateLabelText == expectedExpDate, "Last Four Digits label expected value: \(expectedExpDate), actual value: \(expDateLabelText)")

    }
    
    //check a cc line input existance, value and validity
    func checkCCLineInput(input: XCUIElement, expectedExists: Bool = true, expectedValue: String, invalidError: XCUIElement, expectedValid: Bool = true, isLabel: Bool = false) {
        
        XCTAssertTrue(input.exists == expectedExists, "\(input.identifier) expected to be exists: \(expectedExists), but was exists: \(input.exists)")
        
        if input.exists {
            let value = isLabel ? input.label : input.value as! String
//            let actualValue = (isCcn && !isLabel) ? BSStringUtils.removeNoneDigits(value) : value
//            let expectedValueToCheck = isLabel ? last4Digits: expectedValue
            

            XCTAssertTrue(expectedValue == value, "\(input.identifier) expected value: \(expectedValue), actual value: \(value)")
            
            XCTAssertTrue(invalidError.exists == !expectedValid, "\(input.identifier) invalid error message expected to be exists: \(!expectedValid), but was exists: \(invalidError.exists)")
            
        }
    }
    
    /**
     This test verifies the visibility of inputs - make sure fields are shown according to configuration,
     and that they show the correct content.
     It also verifies that the invalid error messages are not displayed.
     */
    override func checkInputsVisibility(sdkRequest: BSSdkRequest, shopperDetails: BSBaseAddressDetails? = nil, zipLabel: String = "") {
        super.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        let billingDetails = sdkRequest.shopperConfiguration.billingDetails
        checkInput(input: emailInput, expectedExists: sdkRequest.shopperConfiguration.withEmail, expectedValue: billingDetails?.email ?? "", expectedLabelText: "Email")
        checkInput(input: cityInput, expectedExists: sdkRequest.shopperConfiguration.fullBilling, expectedValue: billingDetails?.city ?? "", expectedLabelText: "City")
        checkInput(input: streetInput, expectedExists: sdkRequest.shopperConfiguration.fullBilling, expectedValue: billingDetails?.address ?? "", expectedLabelText: "Street")
        
        if let countryCode = billingDetails?.country {
            //TODO: fix this
            // check country image - this does not work, don;t know how to access the image
            let countryFlagButton = getInputImageButtonElement()
            XCTAssertTrue(countryFlagButton.exists)
//            let countryImage = countryFlagButton.otherElements.images[countryCode]
//            XCTAssertTrue(countryImage.exists)
//            if let expectedImage = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
//                XCTAssertTrue(expectedImage == countryImage)
//            }
            
            // state should be visible for US/Canada/Brazil
            let stateIsVisible = sdkRequest.shopperConfiguration.fullBilling && BSCountryManager.getInstance().countryHasStates(countryCode: countryCode)
            var expectedStateValue = ""
            if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: billingDetails?.state ?? "") {
                expectedStateValue = stateName
            }
            checkInput(input: stateInput, expectedExists: stateIsVisible, expectedValue: expectedStateValue, expectedLabelText: "State")
        }

    }
    
    //Pre-condition: country is USA- for state existence and "Billing Zip" label text
    //Pre-condition: full billing checkout
    //Pre-condition: all cc line and input fields are empty
    override func checkPayWithEmptyInputs(sdkRequest: BSSdkRequest, shopperDetails: BSBaseAddressDetails?, payButtonId: String, zipLabel: String) {
        super.checkPayWithEmptyInputs(sdkRequest: sdkRequest, shopperDetails: shopperDetails, payButtonId: payButtonId, zipLabel: zipLabel)
        checkInput(input: emailInput, expectedValue: "", expectedLabelText: "Email", expectedValid: false)
        checkInput(input: streetInput, expectedValue: "", expectedLabelText: "Street", expectedValid: false)
        checkInput(input: cityInput, expectedValue: "", expectedLabelText: "City", expectedValid: false)
        checkInput(input: stateInput, expectedValue: "", expectedLabelText: "State", expectedValid: false)
        
        // TODO: add this - check how to open the line
        //        checkCcLineInvalidErrorVisibility(input: getCcInputFieldElement(), invalidError: getCcInputErrorLabelElement(), expectedValid: false)
        
        checkCCLineInput(input: getExpInputFieldElement(), expectedValue: "MM/YY", invalidError: getExpInputErrorLabelElement(), expectedValid: false)
        
        checkCCLineInput(input: getCvvInputFieldElement(), expectedValue: "CVV", invalidError: getCvvInputErrorLabelElement(), expectedValid: false)
    }
    
    /**
     This test verifies the invalid error messages appearance for
     the cc line in payment screen
     */
    func checkInvalidCCLineInputs() {
        checkInvalidCCNInputs()
        checkInvalidExpInputs()
        checkInvalidCvvInputs()
        
//        checkInvalidCCLineFieldInputs(input: getCcInputFieldElement(), invalidValuesToCheck: [(getInvalidCreditCardNumber(), false), ("557275888601", true)], validValue: getValidVisaCreditCardNumber(), invalidError: getCcInputErrorLabelElement(),isCcn: true)
//
//        checkInvalidCCLineFieldInputs(input: getExpInputFieldElement(), invalidValuesToCheck: [("2020", false), ("1017", false), ("12", true)], validValue: "1119", invalidError: getExpInputErrorLabelElement())
//
//        checkInvalidCCLineFieldInputs(input: getCvvInputFieldElement(), invalidValuesToCheck: [("45", true), ("1", true)], validValue: "123", invalidError: getCvvInputErrorLabelElement())
    }
    
    func checkInvalidCCNInputs() {
        setAndValidateCCLineFieldInput(input: getCcInputFieldElement(), value: BSUITestUtils.getValidVisaCreditCardNumber(), invalidError: getCcInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false, isCcn: true, last4Digits: "1111")
        
        setAndValidateCCLineFieldInput(input: getCcInputFieldElement(), value: BSUITestUtils.getInvalidCreditCardNumber(), invalidError: getCcInputErrorLabelElement(), expectedValid: false, tapToFocusOut: false, isCcn: true)
        
        setAndValidateCCLineFieldInput(input: getCcInputFieldElement(), value: BSUITestUtils.getValidVisaCreditCardNumber(), invalidError: getCcInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false, isCcn: true, last4Digits: "1111")
        
        setAndValidateCCLineFieldInput(input: getCcInputFieldElement(), value: "5572 7588 8601", invalidError: getCcInputErrorLabelElement(), expectedValid: false, tapToFocusOut: true, isCcn: true)
        
        setAndValidateCCLineFieldInput(input: getCcInputFieldElement(), value: BSUITestUtils.getValidVisaCreditCardNumber(), invalidError: getCcInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false, isCcn: true, last4Digits: "1111")
    }
    
    func checkInvalidExpInputs() {
        setAndValidateCCLineFieldInput(input: getExpInputFieldElement(), value: "11/19", invalidError: getExpInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false)

        setAndValidateCCLineFieldInput(input: getExpInputFieldElement(), value: "20/20", invalidError: getExpInputErrorLabelElement(), expectedValid: false, tapToFocusOut: false)
        
        setAndValidateCCLineFieldInput(input: getExpInputFieldElement(), value: "11/19", invalidError: getExpInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false)
        
        setAndValidateCCLineFieldInput(input: getExpInputFieldElement(), value: "10/17", invalidError: getExpInputErrorLabelElement(), expectedValid: false, tapToFocusOut: false)
        
        setAndValidateCCLineFieldInput(input: getExpInputFieldElement(), value: "11/19", invalidError: getExpInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false)
        
        setAndValidateCCLineFieldInput(input: getExpInputFieldElement(), value: "12", invalidError: getExpInputErrorLabelElement(), expectedValid: false, tapToFocusOut: true)
        
        setAndValidateCCLineFieldInput(input: getExpInputFieldElement(), value: "11/19", invalidError: getExpInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false)
    }
    
    func checkInvalidCvvInputs() {
        setAndValidateCCLineFieldInput(input: getCvvInputFieldElement(), value: "123", invalidError: getCvvInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false)

        setAndValidateCCLineFieldInput(input: getCvvInputFieldElement(), value: "45", invalidError: getCvvInputErrorLabelElement(), expectedValid: false, tapToFocusOut: true)
        
        setAndValidateCCLineFieldInput(input: getCvvInputFieldElement(), value: "123", invalidError: getCvvInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false)
        
        setAndValidateCCLineFieldInput(input: getCvvInputFieldElement(), value: "1", invalidError: getCvvInputErrorLabelElement(), expectedValid: false, tapToFocusOut: true)
        
        setAndValidateCCLineFieldInput(input: getCvvInputFieldElement(), value: "123", invalidError: getCvvInputErrorLabelElement(), expectedValid: true, tapToFocusOut: false)
        
    }
    
    func setAndValidateCCLineFieldInput(input: XCUIElement, value: String, invalidError: XCUIElement, expectedValid: Bool, tapToFocusOut: Bool, isCcn: Bool = false, last4Digits: String = "") {
        setCcLineInput(input: input, value: value, isCcn: isCcn)
        
        if tapToFocusOut {
            //name iput always exists
            getInputFieldElement(nameInput).tap()
        }
        
        if (isCcn && expectedValid){
            waitForElementToExistFunc(getExpInputFieldElement(), 3)
            checkCCLineInput(input: getLast4digitsLabelElement(), expectedValue: last4Digits, invalidError: invalidError, expectedValid: expectedValid, isLabel: true)
        }
        
        else{
            checkCCLineInput(input: input, expectedValue: value, invalidError: invalidError, expectedValid: expectedValid)
        }
    }
    
    /**
     This test verifies the invalid error messages appearance for the billing details
     in payment screen
     Pre-condition: country is USA (for zip existence)
     Pre-condition: full billing is enabled
     */
    override func checkInvalidInfoInputs(payButtonId: String) {
        super.checkInvalidInfoInputs(payButtonId: payButtonId)
        checkInvalidFieldInputs(input: emailInput, invalidValuesToCheck: ["broadwaydancecenter.com", "broadwaydancecenter@gmail"], validValue: "broadwaydancecenter@gmail.com", expectedLabelText: "Email", inputToTap: zipInput)
        
        checkInvalidFieldInputs(input: zipInput, invalidValuesToCheck: ["12"], validValue: "12345 abcde", expectedLabelText: "Billing Zip", inputToTap: streetInput)
    }
    
    func checkMenuButtonEnabled(expectedEnabled: Bool){
        let menuButton = getManuButton()

        XCTAssertTrue(menuButton.isEnabled == expectedEnabled, "Menu button expected to be Enabled: \(expectedEnabled), but was Enabled: \(menuButton.isEnabled)")
    }
    
    func setCurrency(currencyName: String){
        let menuButton = getManuButton()
        menuButton.tap()
        app.sheets.buttons["Currency"].tap()

//        app.searchFields["Search"].tap()
//        app.searchFields["Search"].typeText(currencyName)
        app.tables.staticTexts[currencyName].tap()
    }
    
    // fill in CC details
    func setCcDetails(ccn: String, exp: String, cvv: String) {
        setCcNumber(ccn: ccn)
        
        let expTextField = getExpInputFieldElement()
        waitForElementToExistFunc(expTextField, 3)
//        expTextField.typeText(exp)
        setCcLineInput(input: expTextField, value: exp)
        
        let cvvTextField = getCvvInputFieldElement()
//        cvvTextField.typeText(cvv)
        setCcLineInput(input: cvvTextField, value: cvv)

    }
    
    func setCcNumber(ccn: String) {
//        if (!isOpen) {
//            let ccnCoverButton = getInputCoverButtonElement(ccInput)
//            ccnCoverButton.tap()
//        }
        
        let ccnTextField = getCcInputFieldElement()
        
        if getInputCoverButtonElement(ccLineInput).exists {
            getInputCoverButtonElement(ccLineInput).tap()
            waitForElementToExistFunc(ccnTextField, 3)

        }
        
        ccnTextField.clearText()
        ccnTextField.typeText(ccn)
    }
    
    func setCcLineInput(input: XCUIElement, value: String, isCcn: Bool = false) {
        if isCcn {
            setCcNumber(ccn: value)
        }
            
        else{
            
            input.clearText()
            input.typeText(value)
            
        }
    }
    
    // fill in billing details
    func setFieldValues(billingDetails: BSBillingAddressDetails, sdkRequest: BSSdkRequest, ignoreCountry: Bool? = false) {
        
        setInputValue(input: nameInput, value: billingDetails.name ?? "")
        if sdkRequest.shopperConfiguration.withEmail {
            setInputValue(input: emailInput, value: billingDetails.email ?? "")
        }
        setInputValue(input: zipInput, value: billingDetails.zip ?? "")
        if sdkRequest.shopperConfiguration.fullBilling {
            setInputValue(input: cityInput, value: billingDetails.city ?? "")
            setInputValue(input: streetInput, value: billingDetails.address ?? "")
        }
        if ignoreCountry == false {
            if let countryCode = billingDetails.country {
                setCountry(countryCode: countryCode)
                if sdkRequest.shopperConfiguration.fullBilling {
                    if let stateCode = billingDetails.state {
                        setState(countryCode: countryCode, stateCode: stateCode)
                    }
                }
            }
        }
    }
    
    
    func setShippingSameAsBillingSwitch(shouldBeOn: Bool) {
        
        // set with Shipping switch = on
        let shippingAsBillingSwitch = app.switches["ShippingAsBillingSwitch"]
        let switchValue = (shippingAsBillingSwitch.value as? String) ?? "0"
        if (switchValue == "0" && shouldBeOn) || (switchValue == "1" && !shouldBeOn) {
            shippingAsBillingSwitch.tap()
        }
    }
    
    override func checkPayButton(sdkRequest: BSSdkRequest, shippingSameAsBilling: Bool) {
        var expectedPayText = ""
        
        // checkout without shipping- amout&currency should be displayed, without shipping tax
        if (!sdkRequest.shopperConfiguration.withShipping){
            expectedPayText = "Pay \(sdkRequest.priceDetails.currency == "USD" ? "$" : sdkRequest.priceDetails.currency ?? "USD") \(sdkRequest.priceDetails.amount.doubleValue)"
        }
        
        // checkout with shipping and shipping same as billing is on - amout&currency should be displayed, with shipping tax by billing country&state
        else if (shippingSameAsBilling){
            let country = sdkRequest.shopperConfiguration.billingDetails?.country
            let state = sdkRequest.shopperConfiguration.billingDetails?.state
            
            let includeTaxAmount = BSUITestUtils.calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "", purchaseAmount: sdkRequest.priceDetails.amount.doubleValue)
            expectedPayText = "Pay \(sdkRequest.priceDetails.currency == "USD" ? "$" : sdkRequest.priceDetails.currency ?? "USD") \(includeTaxAmount)"
        }
            
        // checkout with shipping and shipping same as billing is off - continue to shipping should be displayed
        else{
            expectedPayText = "Shipping >"
        }
        
        BSUITestUtils.checkAPayButton(app: app, buttonId: "PayButton", expectedPayText: expectedPayText)
    }
    
    override func checkDoneButton() {
        closeKeyboard()
        BSUITestUtils.checkAPayButton(app: app, buttonId: "PayButton", expectedPayText: "Done")
    }
    
    override func pressPayButton() {
        closeKeyboard()
        app.buttons["PayButton"].tap()
    }
    
    
}
