*** Settings ***
Library     JSONLibrary
Library     os
Library     OperatingSystem
Library     Collections
Library     RequestsLibrary
Library     SeleniumLibrary
Library     String
#Resource    currencies.json
#Resource    ../../Env/dev/internal_currencies.json

*** Variables ***
#${url_api}                  https://dev-api.knstats.com
#${url_cache}                https://ropsten-cache.knstats.com
${url_api}                  https://api.kyber.network
${url_cache}                https://production-cache.kyber.network
${url_tracker}              https://tracker.kyber.network
${currencies}               /currencies
${internal_currencies}      /internal/currencies
${tokens_pairs}             /api/tokens/pairs
${rate}                     /rate

*** Test Cases ***
TC01: Read Data on DEV env from currencies.json
    Create API Session '${url_api}'
    Send Request API '${tokens_pairs}' Response
#    Get Data Currencies From Config File
    Get Detail All Elements Of Tokens Pairs
#    Compare Symbol Name AddressContract Decimals Between Config File Data And Tokens Pairs API Data
#    Verify Current Price Of Tokens Pairs By Visit Etherscan
#    Verify Current Price Of Tokens Pairs By Refer Cache
#    Run Keyword If  '${env}' == 'production'  Verify Last Price Of Tokens Pairs By Refer Tracker
#    Verify Last Price Of Tokens Pairs By Refer Current Price
    Verify Timestamp Of Tokens Pairs By Refer Current Time

*** Keywords ***
Create API Session '${url_api}'
    [Documentation]
    ...     Create a session for API
    Create Session  httprequest     ${url_api}
    set global variable  ${httprequest}    httprequest
    [Return]    ${httprequest}

Send Request API '${api_name}' Response
    ${resp}=     Get Request  ${httprequest}    ${api_name}
    ${jsondata}=  To Json     ${resp.content}
    set global variable  ${resp}    ${resp}
    set global variable  ${jsondata}    ${jsondata}
    [Return]    ${jsondata}

Get Detail All Elements Of Tokens Pairs
    [Documentation]
    ...     1. Get Keys of Tokens Pairs Api. Jsondata is an object (Dictionary in Robot Framework)
    ...     2. Create list related with each param(symbol, name, contractAddress, decimals, currentPrice,lastPrice,lastTimestamp,baseVolume,quoteVolume of response
    ...     3. For loop
    ...         3.1. Get Value related each keys
    ...         3.2. Get each param(symbol, name, contractAddress, decimals, currentPrice,lastPrice,lastTimestamp,baseVolume,quoteVolume related each keys
    ...         3.3. Append to related list
    ${items_tp}=  Get Dictionary Items     ${jsondata}
    ${keys_tp}=  get dictionary keys  ${jsondata}
    ${tokens_pairs_length}=  Get Length  ${keys_tp}
    Set Global Variable  ${tokens_pairs_length}    ${tokens_pairs_length}
    ${symbol_list}=  Create List                                                 #array - list
    set global variable  ${symbolList}  ${symbolList}
    ${name_list}=  Create List
    set global variable  ${nameList}  ${nameList}
    ${contractAddress_list}=  Create List
    set global variable  ${contractAddress_list}  ${contractAddress_list}
    ${decimals_list}=  Create List
    set global variable  ${decimals_list}  ${decimals_list}
    ${currentPrice_list}=  Create List
    set global variable  ${currentPrice_list}  ${currentPrice_list}
    ${lastPrice_list}=  Create List
    set global variable  ${lastPrice_list}  ${lastPrice_list}
    ${lastTimestamp_list}=  Create List
    set global variable  ${lastTimestamp_list}  ${lastTimestamp_list}
    ${baseVolume_list}=  Create List
    set global variable  ${baseVolume_list}  ${baseVolume_list}
    ${quoteVolume_list}=  Create List
    set global variable  ${nameList}  ${nameList}

    FOR     ${i}      IN RANGE     0    ${tokens_pairs_length}
    ${elementValue}=  Get From Dictionary  ${jsondata}     ${keys_tp[${i}]}        #${jsondata} - json object - dictionary
    ${symbol}=  Get Value From Json  ${elementValue}    $.symbol
    Append To List  ${symbol_list}   ${symbol[0]}
    ${name}=  Get Value From Json  ${elementValue}    $.name
    Append To List  ${name_list}   ${name[0]}
    ${contractAddress}=  Get Value From Json  ${elementValue}    $.contractAddress
    Append To List  ${contractAddress_list}   ${contractAddress[0]}
    ${decimals}=  Get Value From Json  ${elementValue}    $.decimals
    Append To List  ${decimals_list}   ${decimals[0]}
    ${currentPrice}=  Get Value From Json  ${elementValue}    $.currentPrice
    Append To List  ${currentPrice_list}   ${currentPrice[0]}
    ${lastPrice}=  Get Value From Json  ${elementValue}    $.lastPrice
    Append To List  ${lastPrice_list}   ${lastPrice[0]}
    ${lastTimestamp}=  Get Value From Json  ${elementValue}    $.lastTimestamp
    Append To List  ${lastTimestamp_list}   ${lastTimestamp[0]}
    ${baseVolume}=  Get Value From Json  ${elementValue}    $.baseVolume
    Append To List  ${baseVolume_list}   ${baseVolume[0]}
    ${quoteVolume}=  Get Value From Json  ${elementValue}    $.quoteVolume
    Append To List  ${quoteVolume_list}   ${quoteVolume[0]}
    END

Get Data Currencies From Config File
    [Documentation]
    ...     1. Get file config data into a variable
    ...     2. Convert a variable above into config json
    ...     3. Get data value
    ...     4. Create list related with each param(symbol, name, address, decimals) of config json
    ...     5. For loop
    ...         5.1 Get each param (symbol, name, address, decimals) of config json
    ...         5.2 Append to related list
    ${currencies_config}=     Get File    D:\\AutomationWorkspace\\RobotFramework\\Projects\\APIExample1\\Env\\${env}\\currencies.json
    ${currencies_config_json}=  to json  ${currencies_config}
    ${data_config}=  Get Value From Json    ${currencies_config_json}    $.data
    Set Global Variable   ${data_config}     ${data_config}
    ${data_config_length}=  Get Length  ${data_config[0]}
    Set Global Variable   ${data_config_length}     ${data_config_length}
    Log     ${data_config_length}
    ####Create List
    ${token_config_list}=  Create List
    Set Global Variable   ${token_config_list}     ${token_config_list}
    ${symbol_config_list}=  Create List       #array - list
    Set Global Variable   ${symbol_config_list}     ${symbol_config_list}
    ${name_config_list}=  Create List
    Set Global Variable   ${name_config_list}     ${name_config_list}
    ${address_config_list}=  Create List
    Set Global Variable   ${address_config_list}     ${address_config_list}
    ${decimals_config_list}=  Create List
    Set Global Variable   ${decimals_config_list}     ${decimals_config_list}

    FOR     ${i}    IN RANGE    0   ${data_config_length}
        ${symbol_config}=   Get Value From Json  ${currencies_config_json}  $.data[${i}].symbol
        Append To List  ${symbol_config_list}   ${symbol_config[0]}
        ${name_config}=   Get Value From Json  ${currencies_config_json}  $.data[${i}].name
        Append To List  ${name_config_list}   ${name_config[0]}
        ${address_config}=   Get Value From Json  ${currencies_config_json}  $.data[${i}].address
        Append To List  ${address_config_list}   ${address_config[0]}
        ${decimals_config}=   Get Value From Json  ${currencies_config_json}  $.data[${i}].decimals
        Append To List  ${decimals_config_list}   ${decimals_config[0]}
    END

Compare Symbol Name AddressContract Decimals Between Config File Data And Tokens Pairs API Data
    [Documentation]
    ...     1. For loop
    ...         1.1. Set variable i to global
    ...         1.2. Run keyword to compare symbol between tokens pairs and config file
    FOR     ${i}     IN RANGE  0   ${tokens_pairs_length}
        Log  ${symbol_list[${i}]}
        set global variable  ${i}   ${i}
        Compare Symbol Data Between Tokens Pairs And Config File
    END

Compare Symbol Data Between Tokens Pairs And Config File
    [Documentation]
    ...     1. For loop
    ...         1.1. Set variable j to global
    ...         1.2. Run keyword if to compare symbol
    ...         1.3. Run keyword to Verify Name ContractData Decimals Data Between Tokens Pairs And Config File
    FOR     ${j}     IN RANGE  0   ${data_config_length}
        set global variable  ${j}   ${j}
        Log  ${symbol_config_list[${j}]}
        run keyword if  '${symbol_list[${i}]}' == '${symbol_config_list[${j}]}'
        ...     Verify Name ContractAddress Decimals Data Between Tokens Pairs And Config File
    END

Verify Name ContractAddress Decimals Data Between Tokens Pairs And Config File
    [Documentation]
    ...     1. Verify name_list from tokens pairs api and name_config_list from file config
    ...     2. Verify contractAddress_list from tokens pairs api and address_config_list from file config
    ...     3. Verify decimals_list from tokens pairs api and decimals_config_list from file config
    Log  ${j}
    Log  ${name_config_list[${j}]}
    Log  ${address_config_list[${j}]}
    Log  ${decimals_config_list[${j}]}
    should be equal as strings  ${name_list[${i}]}      ${name_config_list[${j}]}
    should be equal as strings  ${contractAddress_list[${i}]}      ${address_config_list[${j}]}
    should be equal as strings  ${decimals_list[${i}]}      ${decimals_config_list[${j}]}

Verify Current Price Of Tokens Pairs By Visit Etherscan
    Open Browser    https://ropsten.etherscan.io/   Chrome
    Maximize Browser Window
    Input Text   xpath://input[@id='txtSearchInput']    0xd719c34261e099Fdb33030ac8909d5788D3039C4
    Sleep   2
    Click Element   xpath://button[@class='btn btn-secondary btn-secondary-darkmode']
    Sleep   3
    Click Element   xpath://li[@id='ContentPlaceHolder1_li_contracts']
    Sleep   3

#    Select Frame    xpath://iframe[@id='readcontractiframe']
    Click Element   xpath://li[@id='ContentPlaceHolder1_li_readContract']
    Sleep   5
    Select Frame    xpath://iframe[@id='readcontractiframe']
    Sleep   3
    Set Focus To Element    xpath://input[@id='input_4_1']
    Sleep   2
    Input Text   xpath://input[@id='input_4_1']     0x7b2810576aa1cce68f2b118cef1f36467c648f92
    Sleep   1
    Input Text   xpath://input[@id='input_4_2']     0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
    Sleep   1
    Input Text  xpath://input[@id='input_4_3']      1000000000000000000
    Sleep   1
    Click Element   xpath://button[@id='btn_4']
    Sleep   30
    Set Focus To Element    xpath://input[@id='input_5_1']
    ${expectRate}=  Get Text    xpath://strong[contains(text(),'expectedRate')]
    Log  ${expectRate}
    Unselect Frame

Verify Current Price Of Tokens Pairs By Refer Cache
     Create API Session '${url_cache}'
     Send Request API '${rate}' Response
     Get Rate Tokens From Cache
     Compare Symbol Data Between Tokens Pairs And Cache

#    Get Data Currencies From Config File
#    Get Detail All Elements Of Tokens Pairs
#    Compare Symbol Name AddressContract Decimals Between Config File Data And Tokens Pairs API Data
Get Rate Tokens From Cache
    ${data_cache}=    Get Value From Json  ${jsondata}    $.data
    Set Global Variable     ${data_cache}     ${data_cache}
    Log  ${data_cache}
    ${data_cache_length}=  Get Length   ${data_cache[0]}
    Set Global Variable     ${data_cache_length}     ${data_cache_length}
    ${source_list}=  Create List
    Set Global Variable     ${source_list}  ${source_list}
    ${dest_list}=  Create List
    Set Global Variable     ${dest_list}  ${dest_list}
    ${rate_list}=  Create List
    Set Global Variable     ${rate_list}  ${rate_list}
    Log  ${data_cache_length}
    FOR     ${i}    IN RANGE    0   ${data_cache_length}
        Set Global Variable     ${i}    ${i}
        ${source}=  Get Value From Json  ${jsondata}    $.data[${i}].source
        Append To List  ${source_list}  ${source[0]}
        ${dest}=  Get Value From Json  ${jsondata}    $.data[${i}].dest
        Append To List  ${dest_list}  ${dest[0]}
        ${rate}=  Get Value From Json  ${jsondata}     $.data[${i}].rate
        Append To List  ${rate_list}  ${rate[0]}
    END
    Log  ${source_list}
    Log  ${dest_list}
    Log  ${rate_list}

Compare Symbol Data Between Tokens Pairs And Cache
    ${currentPrice_is_zero_list}=  Create List
    Set Global Variable     ${currentPrice_is_zero_list}    ${currentPrice_is_zero_list}

    FOR     ${i}    IN RANGE    0   ${tokens_pairs_length}
    Set Global Variable   ${i}     ${i}
    ${rate_cache_num_list}=  Create List
    Set Global Variable     ${rate_cache_num_list}   ${rate_cache_num_list}
    ${rate_percentage_list}=  Create List
    Set Global Variable     ${rate_percentage_list}   ${rate_percentage_list}
    Log  ${tokens_pairs_length}
    Log     ${symbol_list[${i}]}
    Log     ${symbol_list}
    Verify If Symbol Tokens Pairs Equal To Source Cache
    Log     ${source_list}
#    Log     ${symbol_list}
    Log     ${rate_cache_num_list}
    END
    Log  ${currentPrice_is_zero_list}
Verify If Symbol Tokens Pairs Equal To Source Cache
    FOR     ${j}    IN RANGE    0   ${data_cache_length}
        Set Global Variable   ${j}     ${j}
        Run Keyword If  '${symbol_list[${i}]}' == '${source_list[${j}]}' and '${dest_list[${j}]}' == 'ETH'
        ...     Run Keywords
        ...     Log Debug Info When Verify If Symbol Tokens Pairs Equal To Source Cache
        ...     AND
        ...     Convert Rate Cache From Gwei To Number Between '${decimals_list[${i}]}' And '${rate_list[${j}]}'
        ...     AND
        ...     Log     ${rate_cache_num_list}
        ...     AND
        ...     Calculate Percentage Between Rate Cache '${currentPrice_list[${i}]}' And CurrentPrice Tokens Pairs '${rate_cache_num_list[0]}'
    END

Log Debug Info When Verify If Symbol Tokens Pairs Equal To Source Cache
    Log     ${i}
    Log     ${j}
    Log     ${symbol_list[${i}]}
    Log     ${dest_list[${j}]}
    Log     ${symbol_list}
    Log     ${source_list}

Verify Rate Between Cache And Tokens Pairs API
    Should Be Equal As Numbers      ${rate_list[${i}]}    ${currentPrice_list[${j}]}

Convert Rate Cache From Gwei To Number Between '${pairs_decimals}' And '${rate_cache_gwei}'
    ${pairs_decimals}=  evaluate  ${pairs_decimals} - 1
    ${rate_cache_num}=  evaluate   (${rate_cache_gwei}/(10e+17))
    Set Global Variable  ${rate_cache_num}  ${rate_cache_num}
    Log     ${rate_cache_num}
    Append To List  ${rate_cache_num_list}   ${rate_cache_num}
    Log     ${rate_cache_num_list}

Calculate Percentage Between Rate Cache '${currentPrice_pairs}' And CurrentPrice Tokens Pairs '${rate_cache_num_list[0]}'
    Run keyword if  '${currentPrice_pairs}' != '0'    Get Rate Percentage Between Rate Cache '${currentPrice_pairs}' And CurrentPrice Tokens Pairs '${rate_cache_num}'
    ...  ELSE IF  '${currentPrice_pairs}' == '0'     Get List Tokens Of Tokens Pairs Has CurrentPrice Equal To 0

Get Rate Percentage Between Rate Cache '${currentPrice_pairs}' And CurrentPrice Tokens Pairs '${rate_cache_num}'
    ${rate_percentage}=     evaluate    (${rate_cache_num}-${currentPrice_pairs})/${currentPrice_pairs}
    Set Global Variable  ${rate_percentage}  ${rate_percentage}
    Log     ${rate_percentage}
    Should Be True  ${rate_percentage} <= 0.05
    Append To List  ${rate_percentage_list}   ${rate_percentage}
    Log     ${rate_percentage_list}

Get List Tokens Of Tokens Pairs Has CurrentPrice Equal To 0
    Log  ${i}
    Append To List  ${currentPrice_is_zero_list}    ${symbol_list[${i}]}
    Log  ${currentPrice_is_zero_list}

Verify Last Price Of Tokens Pairs By Refer Tracker
    Log  ${url_tracker}
    ${2key_symbol}=  Set Variable   2KEY
    ${2key_symbol_length}=  Get Length  ${2key_symbol}
    Log  ${2key_symbol_length}
    ${2key_symbol_length}=  Evaluate    ${2key_symbol_length} + 1
    Log  ${2key_symbol_length}
    Set Global Variable  ${2key_symbol_length}
    Log  ${2key_symbol_length}
    ${2key_address}=  Set variable  /#/tokens/0xe48972fcd82a274411c01834e2f031d4377fa2c0
    Set Global Variable     ${2key_address}  ${2key_address}
    Log  ${2key_address}
    ${url_tracker}=  Set variable  ${url_tracker}${2key_address}
    Log  ${url_tracker}
#    Set Global Variable     ${url_tracker}  ${url_tracker}
    Web - Open Tracker Page With '${url_tracker}'
    Get Last Price Of Token On Traker Page

Web - Open Tracker Page With '${url_tracker}'
    [Documentation]  Open Tracker Page
    set environment variable    webdriver.gecko.driver      /Users/bryan/Documents/Setup/GeckoDriver/0.21.0/geckodriver
    run keyword if      '${browser}' == 'chrome'    Create webdriver    Chrome
    run keyword if      '${browser}' == 'safari'    Create webdriver    Safari
    run keyword if      '${browser}' == 'firefox'    Open Browser    ${user_dashboard_web_url}  firefox
    run keyword if      '${browser}' == 'phantomjs'    Open PhantomJS Browser       ${user_dashboard_admin_web_url}
    Maximize Browser Window
#    Set Window Size    ${browser_width}    ${browser_height}
#    Set Window Size    1280    800
    Go to   ${url_tracker}

Get Last Price Of Token On Traker Page
    ${lastPrice}=  Set variable  0.0002131648186829485
    ${table_cols}=  get element count   xpath://table[@class='table table-responsive table-round table-striped']//tbody//tr[1]//td
    Log To Console  ${table_cols}
    ${latest_rate_text}=  Set Variable  	1 2KEY = 0.000208 ETH
#    ${latest_rate_text}=  get text  xpath://table[@class='table table-responsive table-round table-striped']//tbody//tr[1]//td[3]
    Log  ${latest_rate_text}
#    Log  ${latest_rate_text.strip()}
#    ${latest_rate_text_remove_white_space}=     Strip String  ${latest_rate_text}
#    Log  ${latest_rate_text_remove_white_space}
    ${latest_rate_text_remove_white_space}=     Replace String  ${latest_rate_text}     ${SPACE}    ${EMPTY}
    Log  ${latest_rate_text_remove_white_space}
    ${latest_rate_text_remove_white_space_length}=  Get Length  ${latest_rate_text_remove_white_space}
    ${extract_token_source_symbol}=     Get Substring   ${latest_rate_text_remove_white_space}  1   ${2key_symbol_length}
    Log  ${extract_token_source_symbol}
    ${extract_token_dest_symbol}=   Get Substring   ${latest_rate_text_remove_white_space}  -3
    Log  ${extract_token_dest_symbol}
    ${start_index_rate}=  Evaluate  ${2key_symbol_length} + 2
    ${end_index_rate}=  Evaluate    ${latest_rate_text_remove_white_space_length} - 3
    ${extract_latest_rate}=  Get Substring   ${latest_rate_text_remove_white_space}     ${start_index_rate}     ${end_index_rate}
    Log  ${extract_latest_rate}

Verify Last Price Of Tokens Pairs By Refer Current Price
    ${good_liquidity_tokens_list}=  Create List
    Set Global Variable     ${good_liquidity_tokens_list}    ${good_liquidity_tokens_list}
    ${bad_liquidity_tokens_list}=  Create List
    Set Global Variable     ${bad_liquidity_tokens_list}    ${bad_liquidity_tokens_list}
    ${lastPrice_is_zero_list}=  Create List
    Set Global Variable     ${lastPrice_is_zero_list}    ${lastPrice_is_zero_list}

    FOR     ${i}    IN RANGE    ${tokens_pairs_length}
        Set Global Variable  ${i}   ${i}
        Calculate Percentage Between Current Price '${currentPrice_list[${i}]}' And Last Price '${lastPrice_list[${i}]}' Of Tokens Pairs
    END
    Log  ${good_liquidity_tokens_list}
    ${good_liquidity_tokens_list_length}=   Get Length  ${good_liquidity_tokens_list}
    Log  ${good_liquidity_tokens_list_length}
    Log  ${bad_liquidity_tokens_list}
    ${bad_liquidity_tokens_list_length}=  Get Length  ${bad_liquidity_tokens_list}
    Log  ${bad_liquidity_tokens_list_length}
    ${lastPrice_is_zero_list_length}=  Get Length   ${lastPrice_is_zero_list}
    Log  ${lastPrice_is_zero_list_length}

Calculate Percentage Between Current Price '${currentPrice}' And Last Price '${lastPrice}' Of Tokens Pairs
    ${minus}=  Evaluate  (${currentPrice} - ${lastPrice})
    Set Global Variable     ${minus}    ${minus}
    Log  ${currentPrice}
    Log  ${lastPrice}
    Run Keyword If  '${currentPrice}' != '0'     Get Percentage Between Current Price '${currentPrice}' And Last Price '${lastPrice}' Of Tokens Pairs
    ...     ELSE IF  '${currentPrice}' == '0'     Get List Tokens Of Tokens Pairs Has LastPrice Equal To 0

Get Percentage Between Current Price '${currentPrice}' And Last Price '${lastPrice}' Of Tokens Pairs
    ${current_last_price_percentage}=  Evaluate  (${minus}/${currentPrice})
    Log  ${current_last_price_percentage}
#    Run Keyword If  ${currentPrice} != 0  Get List Tokens
    Run Keyword If  ((${current_last_price_percentage} > 0 and ${current_last_price_percentage} <= 0.01) or (${current_last_price_percentage} < 0 and ${current_last_price_percentage} >= -0.01))  Get List Of Good Liquidity Tokens
    ...     ELSE IF  ((${current_last_price_percentage} > 0.01 and ${current_last_price_percentage} <= 0.1) or (${current_last_price_percentage} < -0.01 and ${current_last_price_percentage} >= -0.1))  Get List Of Bad Liquidity Tokens

#Get List Tokens
#    Run Keyword If  ${current_last_price_percentage}  Get List Of Good Liquidity Tokens
#    ...     ELSE IF  ${current_last_price_percentage} > 0.03 and '${current_last_price_percentage}' <0.1  Get List Of Bad Liquidity Tokens

Get List Of Good Liquidity Tokens
    Log  'Get List Of Good Liquidity Tokens'
    Log  ${i}
    Append To List  ${good_liquidity_tokens_list}    ${symbol_list[${i}]}
    Log  ${good_liquidity_tokens_list}
Get List Of Bad Liquidity Tokens
    Log  'Get List Of Bad Liquidity Tokens'
    Log  ${i}
    Append To List  ${bad_liquidity_tokens_list}    ${symbol_list[${i}]}
    Log  ${bad_liquidity_tokens_list}

Get List Tokens Of Tokens Pairs Has LastPrice Equal To 0
    Log  ${i}
    Append To List  ${lastPrice_is_zero_list}    ${symbol_list[${i}]}
    Log  ${lastPrice_is_zero_list}

Verify Timestamp Of Tokens Pairs By Refer Current Time
    Verify Timestamp Of Tokens Pairs By Refer Current Time
    Get Current Time In Epoch
    FOR  ${i}   IN RANGE    ${tokens_pairs_length}
    Get Minus Between Current Time And Timestamp '${lastTimestamp_list[${i}]}' From API
    END
Get Current Time In Epoch
    ${currentDate}=  Get Current Date
    Log  ${currentDate}
    ${currentDateInEpoch}=  Convert Date  ${currentDate}    epoch
    Set Global Variable  ${currentDateInEpoch}  ${currentDateInEpoch}
    Log  ${currentDateInEpoch}

Get Minus Between Current Time And Timestamp '${timestamp}' From API
    ${minus_timestamp}=  Evaluate  ${currentDateInEpoch} - ${timestamp}
    Log  ${minus_timestamp}
    Should Be True  ${minus_timestamp} < 300














