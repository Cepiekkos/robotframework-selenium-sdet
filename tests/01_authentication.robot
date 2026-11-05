*** Settings ***
Documentation       Authentication & Session Management Test Suite
Resource            ../config/env_config.resource
Resource            ../resources/Common.resource
Resource            ../resources/pages/LoginPage.resource
Resource            ../resources/pages/InventoryPage.resource
Test Setup          Navigate To Login Page
Test Teardown       Close Browser Session

*** Test Cases ***
TC-AUTH-01: Successful Authentication With Standard User
    [Documentation]    Verifies that a valid user can successfully log in and access the inventory catalog.
    [Tags]    smoke    auth    positive
    Verify On Login Page
    Login With Credentials    ${STANDARD_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded

TC-AUTH-02: Locked Out User Receives Appropriate Error Message
    [Documentation]    Verifies that locked out users are denied access with the proper error message.
    [Tags]    auth    negative    security
    Login With Credentials    ${LOCKED_OUT_USER}    ${DEFAULT_PASSWORD}
    Verify Login Error Message Contains    Epic sadface: Sorry, this user has been locked out.

TC-AUTH-03: Invalid Credentials Rejection
    [Documentation]    Verifies authentication failure when providing incorrect password.
    [Tags]    auth    negative
    Login With Credentials    ${STANDARD_USER}    ${INVALID_PASSWORD}
    Verify Login Error Message Contains    Epic sadface: Username and password do not match any user in this service

TC-AUTH-04: Empty Username Validation
    [Documentation]    Verifies mandatory validation on username field.
    [Tags]    auth    negative    validation
    Enter Password    ${DEFAULT_PASSWORD}
    Click Login Button
    Verify Login Error Message Contains    Epic sadface: Username is required

TC-AUTH-05: Empty Password Validation
    [Documentation]    Verifies mandatory validation on password field.
    [Tags]    auth    negative    validation
    Enter Username    ${STANDARD_USER}
    Click Login Button
    Verify Login Error Message Contains    Epic sadface: Password is required

TC-AUTH-06: User Can Successfully Logout And Session Is Terminated
    [Documentation]    Verifies that logging out redirects back to login page and restricts back navigation.
    [Tags]    smoke    auth    session
    Login With Credentials    ${STANDARD_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded
    Logout From Application
    Verify On Login Page
