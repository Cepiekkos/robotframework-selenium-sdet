*** Settings ***
Documentation       Self-Healing Locator Resilience & Dynamic DOM Recovery Test Suite
Resource            ../config/env_config.resource
Resource            ../resources/Common.resource
Resource            ../resources/pages/LoginPage.resource
Resource            ../resources/pages/InventoryPage.resource
Library             ../libraries/AiSelfHealingLocator.py
Test Setup          Navigate To Login Page
Test Teardown       Close Browser Session

*** Test Cases ***
TC-HEAL-01: Self Healing Recovers From Obsolete Username Input Locator
    [Documentation]    Simulates a selector change (e.g. from id:user-name to an unknown selector) and asserts automatic recovery.
    [Tags]    self_healing    ai    resilience
    Verify On Login Page
    # Deliberately supply an invalid / renamed locator
    Smart Input Text    id:user-name-obsolete-v2    ${STANDARD_USER}
    Enter Password    ${DEFAULT_PASSWORD}
    Click Login Button
    Verify Inventory Page Loaded

TC-HEAL-02: Self Healing Recovers From Renamed Submit Button Locator
    [Documentation]    Simulates a changed button ID/class and verifies the dynamic heuristic click resolution.
    [Tags]    self_healing    ai    resilience
    Enter Username    ${STANDARD_USER}
    Enter Password    ${DEFAULT_PASSWORD}
    # Deliberately supply a broken locator for login button
    Smart Click Element    css:.btn-submit-login-primary
    Verify Inventory Page Loaded

TC-HEAL-03: End-To-End Authentication Using Exclusively Broken Locators
    [Documentation]    Exercises the self-healing engine on multiple failing elements in sequence (username, password, and button).
    [Tags]    self_healing    ai    resilience    e2e
    # Both inputs and the button use intentionally deprecated locators
    Smart Input Text    input-login-user-field    ${STANDARD_USER}
    Smart Input Text    input-security-password-field    ${DEFAULT_PASSWORD}
    Smart Click Element    button-authenticate-submit
    Verify Inventory Page Loaded
    
    # Assert that self healing captured and reported all 3 events
    ${history}=    Get Self Healing Summary
    ${count}=    Get Length    ${history}
    Should Be True    ${count} >= 3
    Log    Total Elements Successfully Healed: ${count}
