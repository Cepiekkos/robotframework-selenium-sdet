*** Settings ***
Documentation       Global Common Keywords and Lifecycle Hooks
Resource            ../config/env_config.resource
Library             SeleniumLibrary
Library             OperatingSystem

*** Keywords ***
Open Browser To Application
    [Documentation]    Launches the configured browser with optimal flags and navigates to the application URL.
    [Arguments]    ${url}=${BASE_URL}    ${browser_type}=${BROWSER}
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${is_headless}=    Evaluate    'headless' in '${browser_type}'.lower()
    IF    ${is_headless}
        Call Method    ${options}    add_argument    --headless\=new
    END
    Call Method    ${options}    add_argument    --disable-gpu
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --window-size\=${WINDOW_WIDTH},${WINDOW_HEIGHT}
    
    ${driver_name}=    Set Variable If    'chrome' in '${browser_type}'.lower()    chrome    ${browser_type}
    Open Browser    ${url}    ${driver_name}    options=${options}
    Set Selenium Speed    ${SELENIUM_SPEED}
    Set Selenium Timeout    ${DEFAULT_TIMEOUT}
    Set Window Size    ${WINDOW_WIDTH}    ${WINDOW_HEIGHT}

Close Browser Session
    [Documentation]    Tears down the browser session safely.
    Close All Browsers

Capture Screenshot On Failure
    [Documentation]    Captures screenshot only when the test status is FAIL.
    Run Keyword If Test Failed    Capture Page Screenshot    EMBED
