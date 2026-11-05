*** Settings ***
Documentation       Page Object for the SauceDemo Login Page
Resource            ../../config/env_config.resource
Resource            ../Common.resource
Library             SeleniumLibrary

*** Variables ***
${LOGIN_USERNAME_INPUT}         id:user-name
${LOGIN_PASSWORD_INPUT}         id:password
${LOGIN_SUBMIT_BUTTON}          id:login-button
${LOGIN_ERROR_MESSAGE}          css:[data-test="error"]
${LOGIN_LOGO}                   css:.login_logo
${LOGIN_CREDENTIALS_BOX}        id:login_credentials

*** Keywords ***
Navigate To Login Page
    [Documentation]    Opens the browser directly to the SauceDemo login page.
    Open Browser To Application    ${BASE_URL}

Verify On Login Page
    [Documentation]    Asserts that login input fields and logo are visible.
    Wait Until Element Is Visible    ${LOGIN_LOGO}    timeout=5s
    Wait Until Element Is Visible    ${LOGIN_USERNAME_INPUT}
    Wait Until Element Is Visible    ${LOGIN_PASSWORD_INPUT}
    Wait Until Element Is Visible    ${LOGIN_SUBMIT_BUTTON}

Enter Username
    [Documentation]    Types the username into the username field.
    [Arguments]    ${username}
    Clear Element Text    ${LOGIN_USERNAME_INPUT}
    Input Text    ${LOGIN_USERNAME_INPUT}    ${username}

Enter Password
    [Documentation]    Types the password into the password field.
    [Arguments]    ${password}
    Clear Element Text    ${LOGIN_PASSWORD_INPUT}
    Input Password    ${LOGIN_PASSWORD_INPUT}    ${password}

Click Login Button
    [Documentation]    Submits the login form.
    Click Button    ${LOGIN_SUBMIT_BUTTON}

Login With Credentials
    [Documentation]    High-level keyword to log in with given username and password.
    [Arguments]    ${username}    ${password}
    Enter Username    ${username}
    Enter Password    ${password}
    Click Login Button

Verify Login Error Message Contains
    [Documentation]    Asserts that the error banner contains expected text.
    [Arguments]    ${expected_error_text}
    Wait Until Element Is Visible    ${LOGIN_ERROR_MESSAGE}    timeout=5s
    ${actual_error}=    Get Text    ${LOGIN_ERROR_MESSAGE}
    Should Contain    ${actual_error}    ${expected_error_text}
