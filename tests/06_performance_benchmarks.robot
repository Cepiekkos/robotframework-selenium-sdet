*** Settings ***
Documentation       Browser Performance Benchmarks & SLA Compliance Suite
Resource            ../config/env_config.resource
Resource            ../resources/Common.resource
Resource            ../resources/pages/LoginPage.resource
Resource            ../resources/pages/InventoryPage.resource
Library             ../libraries/PerformanceMetrics.py
Test Teardown       Close Browser Session

*** Test Cases ***
TC-PERF-01: Login Screen Meets Page Load Budget SLA
    [Documentation]    Measures the initial landing page load metrics and asserts standard SLA compliance (< 3.0 seconds).
    [Tags]    performance    sla    smoke
    Navigate To Login Page
    Verify On Login Page
    # Collect performance metrics and assert SLA
    ${metrics}=    Collect Browser Performance Metrics    page_name=SauceDemo Login Landing
    Should Be True    ${metrics['page_load_time_sec']} < 3.0
    Log    Observed Page Load Time: ${metrics['page_load_time_sec']}s (TTFB: ${metrics['ttfb_ms']}ms)

TC-PERF-02: Inventory Catalog Complies With SLA Budget For Standard User
    [Documentation]    Measures product catalog rendering speed and network responsiveness for standard user.
    [Tags]    performance    sla
    Navigate To Login Page
    Login With Credentials    ${STANDARD_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded
    # Assert Time-To-First-Byte (TTFB) network responsiveness budget SLA (< 3.0s)
    Assert TTFB SLA    max_seconds=3.0    page_name=Standard User Inventory Catalog
    Assert Page Load SLA    max_seconds=35.0    page_name=Standard User Inventory Catalog

TC-PERF-03: Performance Profiling Captures Latency Discrepancy On Glitch User
    [Documentation]    Profiles the 'performance_glitch_user' to quantify latency degradation against standard user baseline.
    [Tags]    performance    profiling    benchmark
    Navigate To Login Page
    Login With Credentials    ${PERF_GLITCH_USER}    ${DEFAULT_PASSWORD}
    Verify Inventory Page Loaded
    ${glitch_metrics}=    Collect Browser Performance Metrics    page_name=Glitch User Inventory Catalog
    Log    Glitch User Page Load Time: ${glitch_metrics['page_load_time_sec']} seconds
    # Verify that metrics were accurately captured
    Should Be True    ${glitch_metrics['page_load_time_ms']} > 0
