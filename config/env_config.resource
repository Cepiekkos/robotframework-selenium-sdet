*** Settings ***
Documentation       Global Environment Configurations and Variables

*** Variables ***
${BASE_URL}                 https://www.saucedemo.com
${BROWSER}                  headlesschrome
${DEFAULT_TIMEOUT}          10s
${SELENIUM_SPEED}           0.0s
${WINDOW_WIDTH}             1920
${WINDOW_HEIGHT}            1080

# User credentials from SauceDemo standard catalog
${STANDARD_USER}            standard_user
${LOCKED_OUT_USER}          locked_out_user
${PROBLEM_USER}             problem_user
${PERF_GLITCH_USER}         performance_glitch_user
${ERROR_USER}               error_user
${VISUAL_USER}              visual_user
${DEFAULT_PASSWORD}         secret_sauce
${INVALID_PASSWORD}         invalid_sauce_password
