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
Set React Input Value
    [Documentation]    Sets input value and dispatches native React input & change events.
    [Arguments]    ${element_id}    ${value}
    Execute Javascript    const el = document.getElementById(arguments[0]); if (el) { const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set; setter.call(el, arguments[1]); el.dispatchEvent(new Event('input', { bubbles: true })); el.dispatchEvent(new Event('change', { bubbles: true })); }    ARGUMENTS    ${element_id}    ${value}

Fill Checkout Information
    [Documentation]    Inputs customer details on checkout step 1 with React state dispatch.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}    timeout=10s
    Set React Input Value    first-name     ${first_name}
    Set React Input Value    last-name      ${last_name}
    Set React Input Value    postal-code    ${postal_code}
    Sleep    0.3s

Continue Checkout
    [Documentation]    Submits customer info and navigates to order overview.
    Wait Until Element Is Visible    ${CONTINUE_BUTTON}    timeout=10s
    ${btn}=    Get WebElement    ${CONTINUE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn}
    Sleep    0.5s

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
    Wait Until Element Is Visible    ${FINISH_BUTTON}    timeout=10s
    ${btn}=    Get WebElement    ${FINISH_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn}
    Sleep    0.5s

Verify Order Completion Success
    [Documentation]    Asserts confirmation headline is displayed.
    Wait Until Element Is Visible    ${ORDER_COMPLETE_HEADER}    timeout=10s
    ${msg}=    Get Text    ${ORDER_COMPLETE_HEADER}
    Should Be Equal As Strings    ${msg}    Thank you for your order!
    Wait Until Element Is Visible    ${BACK_HOME_BUTTON}    timeout=10s
