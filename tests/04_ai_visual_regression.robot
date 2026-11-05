*** Settings ***
Documentation       AI-Powered Visual Regression & Anomaly Diagnostic Test Suite
Resource            ../config/env_config.resource
Resource            ../resources/Common.resource
Resource            ../resources/pages/LoginPage.resource
Resource            ../resources/pages/InventoryPage.resource
Library             ../libraries/AiVisualValidator.py
Test Teardown       Close Browser Session

*** Test Cases ***
TC-VIS-01: Establish And Verify Baseline For Login View
    [Documentation]    Establishes the visual reference baseline for the unauthenticated login viewport.
    [Tags]    visual    ai    baseline
    Navigate To Login Page
    Verify On Login Page
    # First execution generates baseline; subsequent runs assert visual parity
    ${result}=    Compare Visual Baseline    login_screen_baseline    threshold_percent=3.5
    Should Be True    ${result['diff_percent']} <= 3.5

TC-VIS-02: AI Anomaly Detection Identifies Visual Regressions On Visual User
    [Documentation]    Leverages SauceDemo's 'visual_user' to detect intentional layout shifts and broken image assets using AI Visual Inspector.
    [Tags]    visual    ai    anomaly_detection
    # 1. Establish clean baseline using standard user
    Navigate To Login Page
    Login With Credentials    ${STANDARD_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded
    Wait Until Page Contains Element    css:.inventory_item_img
    Sleep    1s
    Create Visual Baseline    inventory_catalog_clean_baseline
    Close Browser Session
    
    # 2. Login as 'visual_user' which exhibits visual glitches and layout drifts
    Navigate To Login Page
    Login With Credentials    ${VISUAL_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded
    Wait Until Page Contains Element    css:.inventory_item_img
    Sleep    1s
    
    # 3. Perform AI visual regression comparison
    ${diff_result}=    Compare Visual Baseline    inventory_catalog_clean_baseline    threshold_percent=0.5
    
    # 4. Assert that visual regressions were captured and AI diagnostics generated
    Log    Visual Difference Detected: ${diff_result['diff_percent']}%
    Should Be True    ${diff_result['diff_percent']} > 0.5    msg=Visual discrepancy should be detected for visual_user!
    Should Not Be Empty    ${diff_result['diagnostics']}
    Log    AI Diagnostic Summary: ${diff_result['diagnostics']['summary']}
    Should Contain    ${diff_result['diagnostics']['summary']}    detected

TC-VIS-03: Clean Visual Verification For Standard User Catalog
    [Documentation]    Asserts that standard user catalog remains compliant with baseline without layout defects.
    [Tags]    visual    standard
    Navigate To Login Page
    Login With Credentials    ${STANDARD_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded
    Wait Until Page Contains Element    css:.inventory_item_img
    Sleep    1s
    ${result}=    Compare Visual Baseline    inventory_catalog_clean_baseline    threshold_percent=3.5
    Should Be True    ${result['diff_percent']} <= 3.5
