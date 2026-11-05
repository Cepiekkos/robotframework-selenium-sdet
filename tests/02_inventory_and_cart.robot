*** Settings ***
Documentation       Inventory Catalog & Shopping Cart Test Suite
Resource            ../config/env_config.resource
Resource            ../resources/Common.resource
Resource            ../resources/pages/LoginPage.resource
Resource            ../resources/pages/InventoryPage.resource
Resource            ../resources/pages/CartPage.resource
Test Setup          Open Application And Login As Standard User
Test Teardown       Close Browser Session

*** Keywords ***
Open Application And Login As Standard User
    Navigate To Login Page
    Login With Credentials    ${STANDARD_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded

*** Test Cases ***
TC-INV-01: Verify Product Sorting By Price Low To High
    [Documentation]    Verifies that items are ordered ascending by price.
    [Tags]    inventory    sorting    regression
    Sort Products    lohi
    Verify Products Sorted By Price Ascending

TC-INV-02: Verify Product Sorting By Price High To Low
    [Documentation]    Verifies that items are ordered descending by price.
    [Tags]    inventory    sorting    regression
    Sort Products    hilo
    Verify Products Sorted By Price Descending

TC-INV-03: Verify Product Sorting By Name Alphabetical A To Z
    [Documentation]    Verifies product titles are ordered alphabetically from A to Z.
    [Tags]    inventory    sorting    smoke
    Sort Products    az
    Verify Products Sorted By Name Ascending

TC-INV-04: Add Multiple Items And Verify Shopping Cart Badge Count
    [Documentation]    Verifies that adding products dynamically updates the cart count.
    [Tags]    cart    functional    smoke
    ${initial_count}=    Get Cart Item Count
    Should Be Equal As Integers    ${initial_count}    0
    
    Add Product To Cart By Name    Sauce Labs Backpack
    ${count_1}=    Get Cart Item Count
    Should Be Equal As Integers    ${count_1}    1
    
    Add Product To Cart By Name    Sauce Labs Bike Light
    ${count_2}=    Get Cart Item Count
    Should Be Equal As Integers    ${count_2}    2

TC-INV-05: Remove Item From Inventory Page Updates Cart Badge
    [Documentation]    Verifies removing an added item decrements the cart count.
    [Tags]    cart    functional
    Add Product To Cart By Name    Sauce Labs Backpack
    ${count_after_add}=    Get Cart Item Count
    Should Be Equal As Integers    ${count_after_add}    1
    
    Remove Product From Cart By Name    Sauce Labs Backpack
    ${count_after_remove}=    Get Cart Item Count
    Should Be Equal As Integers    ${count_after_remove}    0

TC-INV-06: Cart State Persists Upon Browser Refresh
    [Documentation]    Verifies cart items remain cached in session after page reload.
    [Tags]    cart    persistence
    Add Product To Cart By Name    Sauce Labs Bolt T-Shirt
    Reload Page
    Verify Inventory Page Loaded
    ${count}=    Get Cart Item Count
    Should Be Equal As Integers    ${count}    1
    Navigate To Shopping Cart
    Verify Cart Page Loaded
    Verify Product Present In Cart    Sauce Labs Bolt T-Shirt
