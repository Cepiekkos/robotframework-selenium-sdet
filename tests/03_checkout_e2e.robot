*** Settings ***
Documentation       End-To-End Purchase Flow & Checkout Boundary Validation Suite
Resource            ../config/env_config.resource
Resource            ../resources/Common.resource
Resource            ../resources/pages/LoginPage.resource
Resource            ../resources/pages/InventoryPage.resource
Resource            ../resources/pages/CartPage.resource
Resource            ../resources/pages/CheckoutPage.resource
Library             ../libraries/TestDataGenerator.py
Test Setup          Open Application And Prepare Cart Items
Test Teardown       Close Browser Session

*** Keywords ***
Open Application And Prepare Cart Items
    Navigate To Login Page
    Login With Credentials    ${STANDARD_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded
    Add Product To Cart By Name    Sauce Labs Backpack
    Add Product To Cart By Name    Sauce Labs Fleece Jacket
    Navigate To Shopping Cart
    Verify Cart Page Loaded
    Proceed To Checkout

*** Test Cases ***
TC-E2E-01: Complete Happy Path Purchase Flow With Dynamic Test Data
    [Documentation]    Executes full checkout lifecycle using dynamically generated customer persona.
    [Tags]    e2e    smoke    checkout
    ${user_data}=    Generate Random Checkout User
    Fill Checkout Information    ${user_data['first_name']}    ${user_data['last_name']}    ${user_data['postal_code']}
    Continue Checkout

    # Verify Step 2 Overview Financial Calculations
    Verify Tax Calculation
    ${fin}=    Get Order Financials
    Should Be True    ${fin['total']} > 0

    Finish Order
    Verify Order Completion Success

TC-E2E-02: Boundary Validation On Missing First Name
    [Documentation]    Verifies field validation when first name is left blank.
    [Tags]    checkout    boundary    negative
    Fill Checkout Information    ${EMPTY}    Smith    94016
    Continue Checkout
    Verify Checkout Error Contains    Error: First Name is required

TC-E2E-03: Boundary Validation On Missing Last Name
    [Documentation]    Verifies field validation when last name is left blank.
    [Tags]    checkout    boundary    negative
    Fill Checkout Information    John    ${EMPTY}    94016
    Continue Checkout
    Verify Checkout Error Contains    Error: Last Name is required

TC-E2E-04: Boundary Validation On Missing Postal Code
    [Documentation]    Verifies field validation when postal code is left blank.
    [Tags]    checkout    boundary    negative
    Fill Checkout Information    John    Smith    ${EMPTY}
    Continue Checkout
    Verify Checkout Error Contains    Error: Postal Code is required

TC-E2E-05: Resilience Against Script Injection In Checkout Fields
    [Documentation]    Verifies form properly sanitizes special characters without executing scripts.
    [Tags]    security    checkout
    Fill Checkout Information    <script>alert(1)</script>    Doe    94016
    Continue Checkout
    # Should proceed normally to overview without JavaScript alerts breaking DOM
    Verify Tax Calculation
