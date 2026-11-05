*** Settings ***
Documentation       Page Object for the SauceDemo Products Inventory Catalog
Resource            ../../config/env_config.resource
Resource            ../Common.resource
Library             SeleniumLibrary
Library             Collections
Library             String

*** Variables ***
${INVENTORY_CONTAINER}          id:inventory_container
${INVENTORY_ITEM}               css:.inventory_item
${INVENTORY_ITEM_NAME}          css:.inventory_item_name
${INVENTORY_ITEM_PRICE}         css:.inventory_item_price
${SORT_DROPDOWN}                css:[data-test="product-sort-container"]
${CART_LINK}                    css:.shopping_cart_link
${CART_BADGE}                   css:.shopping_cart_badge
${MENU_BUTTON}                  id:react-burger-menu-btn
${LOGOUT_LINK}                  id:logout_sidebar_link

*** Keywords ***
Verify Inventory Page Loaded
    [Documentation]    Asserts that the product catalog and header elements are displayed.
    Wait Until Element Is Visible    ${INVENTORY_CONTAINER}    timeout=10s
    Wait Until Element Is Visible    ${SORT_DROPDOWN}
    Wait Until Element Is Visible    ${CART_LINK}

Sort Products
    [Documentation]    Selects sorting option: 'az', 'za', 'lohi', or 'hilo'.
    [Arguments]    ${sort_option}
    Select From List By Value    ${SORT_DROPDOWN}    ${sort_option}

Get All Product Prices
    [Documentation]    Returns a list of numeric floats representing all item prices on the page.
    ${elements}=    Get WebElements    ${INVENTORY_ITEM_PRICE}
    ${prices}=    Create List
    FOR    ${el}    IN    @{elements}
        ${raw_text}=    Get Text    ${el}
        ${cleaned}=    Remove String    ${raw_text}    $
        ${val}=    Convert To Number    ${cleaned}
        Append To List    ${prices}    ${val}
    END
    RETURN    ${prices}

Get All Product Names
    [Documentation]    Returns a list of string titles of all items on the page.
    ${elements}=    Get WebElements    ${INVENTORY_ITEM_NAME}
    ${names}=    Create List
    FOR    ${el}    IN    @{elements}
        ${t}=    Get Text    ${el}
        Append To List    ${names}    ${t}
    END
    RETURN    ${names}

Verify Products Sorted By Price Ascending
    [Documentation]    Asserts prices are strictly sorted low to high.
    ${prices}=    Get All Product Prices
    ${sorted_prices}=    Copy List    ${prices}
    Sort List    ${sorted_prices}
    Lists Should Be Equal    ${prices}    ${sorted_prices}

Verify Products Sorted By Price Descending
    [Documentation]    Asserts prices are strictly sorted high to low.
    ${prices}=    Get All Product Prices
    ${sorted_prices}=    Copy List    ${prices}
    Sort List    ${sorted_prices}
    Reverse List    ${sorted_prices}
    Lists Should Be Equal    ${prices}    ${sorted_prices}

Verify Products Sorted By Name Ascending
    [Documentation]    Asserts product names are sorted alphabetically A to Z.
    ${names}=    Get All Product Names
    ${sorted_names}=    Copy List    ${names}
    Sort List    ${sorted_names}
    Lists Should Be Equal    ${names}    ${sorted_names}

Add Product To Cart By Name
    [Documentation]    Finds item card by title and clicks its 'Add to cart' button.
    [Arguments]    ${product_title}
    ${btn_locator}=    Set Variable    xpath://div[contains(@class,'inventory_item')][.//div[text()='${product_title}']]//button
    Wait Until Element Is Visible    ${btn_locator}
    Click Button    ${btn_locator}

Remove Product From Cart By Name
    [Documentation]    Clicks the Remove button for a specific product on the inventory page.
    [Arguments]    ${product_title}
    ${btn_locator}=    Set Variable    xpath://div[contains(@class,'inventory_item')][.//div[text()='${product_title}']]//button[text()='Remove']
    Wait Until Element Is Visible    ${btn_locator}
    Click Button    ${btn_locator}

Get Cart Item Count
    [Documentation]    Returns current integer count displayed on the shopping cart badge, or 0 if empty.
    ${has_badge}=    Run Keyword And Return Status    Page Should Contain Element    ${CART_BADGE}
    IF    ${has_badge}
        ${badge_text}=    Get Text    ${CART_BADGE}
        ${count}=    Convert To Integer    ${badge_text}
        RETURN    ${count}
    ELSE
        RETURN    ${0}
    END

Navigate To Shopping Cart
    [Documentation]    Clicks the shopping cart badge icon to view cart.
    Wait Until Element Is Visible    ${CART_LINK}    timeout=5s
    Click Element    ${CART_LINK}
    Wait Until Page Contains Element    id:checkout    timeout=10s

Logout From Application
    [Documentation]    Opens side menu and clicks logout link.
    Click Button    ${MENU_BUTTON}
    Wait Until Element Is Visible    ${LOGOUT_LINK}    timeout=5s
    Click Element    ${LOGOUT_LINK}
    Wait Until Element Is Visible    id:login-button
