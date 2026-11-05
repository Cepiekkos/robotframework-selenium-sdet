*** Settings ***
Documentation       Page Object for SauceDemo Shopping Cart Review Page
Resource            ../../config/env_config.resource
Resource            ../Common.resource
Library             SeleniumLibrary
Library             Collections

*** Variables ***
${CART_CONTAINER}               id:cart_contents_container
${CART_ITEM}                    css:.cart_item
${CART_ITEM_NAME}               css:.inventory_item_name
${CHECKOUT_BUTTON}              id:checkout
${CONTINUE_SHOPPING_BUTTON}     id:continue-shopping

*** Keywords ***
Verify Cart Page Loaded
    [Documentation]    Asserts user is on the cart review screen.
    Wait Until Page Contains Element    ${CHECKOUT_BUTTON}    timeout=10s
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}    timeout=10s

Verify Product Present In Cart
    [Documentation]    Asserts specified product name is displayed in cart.
    [Arguments]    ${product_title}
    Page Should Contain Element    xpath://div[@class='cart_item']//div[text()='${product_title}']

Remove Product From Cart
    [Documentation]    Clicks Remove on a product inside cart page.
    [Arguments]    ${product_title}
    Click Button    xpath://div[@class='cart_item'][.//div[text()='${product_title}']]//button[text()='Remove']

Proceed To Checkout
    [Documentation]    Clicks Checkout button to initiate checkout flow.
    Wait Until Page Contains Element    ${CHECKOUT_BUTTON}    timeout=10s
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}    timeout=10s
    Scroll Element Into View    ${CHECKOUT_BUTTON}
    Click Element    ${CHECKOUT_BUTTON}
    ${transitioned}=    Run Keyword And Return Status    Wait Until Element Is Visible    id:first-name    timeout=5s
    IF    not ${transitioned}
        Execute Javascript    document.getElementById('checkout').click()
        Wait Until Element Is Visible    id:first-name    timeout=10s
    END

Return To Inventory
    [Documentation]    Clicks Continue Shopping button.
    Click Button    ${CONTINUE_SHOPPING_BUTTON}
