*** Settings ***
Documentation       Page Object for SauceDemo Checkout Workflows (Step 1, Step 2, and Order Completion)
Resource            ../../config/env_config.resource
Resource            ../Common.resource
Library             SeleniumLibrary
Library             String

*** Variables ***
${FIRST_NAME_INPUT}             id:first-name
${LAST_NAME_INPUT}              id:last-name
${POSTAL_CODE_INPUT}            id:postal-code
${CONTINUE_BUTTON}              id:continue
${CANCEL_BUTTON}                id:cancel
${CHECKOUT_ERROR}               css:[data-test="error"]

${SUBTOTAL_LABEL}               css:[data-test="subtotal-label"]
${TAX_LABEL}                    css:[data-test="tax-label"]
${TOTAL_LABEL}                  css:[data-test="total-label"]
${FINISH_BUTTON}                id:finish

${ORDER_COMPLETE_HEADER}        css:.complete-header
${BACK_HOME_BUTTON}             id:back-to-products

*** Keywords ***
Fill Checkout Information
    [Documentation]    Inputs customer details on checkout step 1.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}    timeout=5s
    Clear Element Text    ${FIRST_NAME_INPUT}
    Input Text    ${FIRST_NAME_INPUT}    ${first_name}
    Clear Element Text    ${LAST_NAME_INPUT}
    Input Text    ${LAST_NAME_INPUT}    ${last_name}
    Clear Element Text    ${POSTAL_CODE_INPUT}
    Input Text    ${POSTAL_CODE_INPUT}    ${postal_code}

Continue Checkout
    [Documentation]    Submits customer info and navigates to order overview.
    Wait Until Element Is Visible    ${CONTINUE_BUTTON}    timeout=5s
    Execute Javascript    document.getElementById('continue').click()

Verify Checkout Error Contains
    [Documentation]    Validates error on checkout form.
    [Arguments]    ${expected_msg}
    Wait Until Element Is Visible    ${CHECKOUT_ERROR}    timeout=5s
    ${text}=    Get Text    ${CHECKOUT_ERROR}
    Should Contain    ${text}    ${expected_msg}

Get Order Financials
    [Documentation]    Extracts item subtotal, calculated tax, and final total amounts as numbers.
    Wait Until Page Contains Element    ${SUBTOTAL_LABEL}    timeout=10s
    Wait Until Element Is Visible    ${SUBTOTAL_LABEL}    timeout=10s
    ${sub_raw}=    Get Text    ${SUBTOTAL_LABEL}
    ${tax_raw}=    Get Text    ${TAX_LABEL}
    ${tot_raw}=    Get Text    ${TOTAL_LABEL}

    # Format: "Item total: $29.99"
    ${sub_clean}=    Fetch From Right    ${sub_raw}    $
    ${tax_clean}=    Fetch From Right    ${tax_raw}    $
    ${tot_clean}=    Fetch From Right    ${tot_raw}    $

    ${subtotal}=    Convert To Number    ${sub_clean}
    ${tax}=    Convert To Number    ${tax_clean}
    ${total}=    Convert To Number    ${tot_clean}

    ${financials}=    Create Dictionary    subtotal=${subtotal}    tax=${tax}    total=${total}
    RETURN    ${financials}

Verify Tax Calculation
    [Documentation]    Asserts that tax + subtotal mathematically equals the final total displayed.
    ${fin}=    Get Order Financials
    ${calc_total}=    Evaluate    round(${fin['subtotal']} + ${fin['tax']}, 2)
    ${displayed_total}=    Set Variable    ${fin['total']}
    Should Be Equal As Numbers    ${calc_total}    ${displayed_total}    precision=2

Finish Order
    [Documentation]    Submits the final checkout confirmation.
    Wait Until Element Is Visible    ${FINISH_BUTTON}
    Click Button    ${FINISH_BUTTON}

Verify Order Completion Success
    [Documentation]    Asserts confirmation headline is displayed.
    Wait Until Element Is Visible    ${ORDER_COMPLETE_HEADER}    timeout=5s
    ${msg}=    Get Text    ${ORDER_COMPLETE_HEADER}
    Should Be Equal As Strings    ${msg}    Thank you for your order!
    Wait Until Element Is Visible    ${BACK_HOME_BUTTON}
