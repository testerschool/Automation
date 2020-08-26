*** Settings ***
Library     JSONLibrary
Library     os
Library     OperatingSystem
Library     Collections
Library     RequestsLibrary
Library  SeleniumLibrary
#Resource    currencies.json
#Resource    ../../Env/dev/internal_currencies.json

*** Variables ***
#${url_api}                  https://dev-api.knstats.com
#${url_cache}                https://ropsten-cache.knstats.com
${url_api}                  https://api.kyber.network
${url_cache}                https://production-cache.kyber.network
${currencies}               /currencies
${internal_currencies}      /internal/currencies
${tokens_pairs}             /api/tokens/pairs
${rate}                     /rate

*** Test Cases ***
TC01: Read Data on DEV env from currencies.json
    Create API Session '${url_api}'
    Send Request API '${tokens_pairs}' Response
    Get Data Currencies From Config File
    Get Detail All Elements Of Tokens Pairs
    Compare Symbol Name AddressContract Decimals Between Config File Data And Tokens Pairs API Data
#    Verify Current Price Of Tokens Pairs By Visit Etherscan
    Verify Current Price Of Tokens Pairs By Refer Cache


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

#    Get Data Currencies From Config File
#    Get Detail All Elements Of Tokens Pairs
#    Compare Symbol Name AddressContract Decimals Between Config File Data And Tokens Pairs API Data
Get Rate Tokens From Cache
    ${data_cache}=    Get Value From Json  ${jsondata}    $.data
    Set Global Variable     ${data_cache}     ${data_cache}
    Log  ${data_cache}
    ${data_cache_length}=  Get Length   ${data_cache[0]}
    ${source_list}=  Create List
    Set Global Variable     ${source_list}  ${source_list}
    ${rate_list}=  Create List
    Set Global Variable     ${rate_list}  ${rate_list}


    FOR     ${i}    IN RANGE    0   ${data_cache_length}
        Set Global Variable     ${i}    ${i}
        ${source}=  Get Value From Json  ${jsondata}    $.data[${i}].source
        Append To List  ${source_list}  ${source[0]}
        ${rate}=  Get Value From Json  ${jsondata}     $.data[${i}].rate
        Append To List  ${rate_list}  ${rate[0]}
        Compare Symbol Data Between Cache And Tokens Pairs
    END

Compare Symbol Data Between Cache And Tokens Pairs
#    ${test_list}=  Set Variable     0
    FOR     ${j}    IN RANGE    0   ${tokens_pairs_length}
#
        Set Global Variable   ${j}     ${j}
#        ${currentPrice_list[${j}]}=   Evaluate     ${currentPrice_list[${j}]}*${decimals_list[${j}]}

        Run Keyword If  '${source_list[${i}]}' == '${symbol_list[${j}]}'
        ...     Run Keywords
#        ...     ${rate_list[${i}]}=  Convert To Number  ${rate_list[${i}]}
#        ...     AND
#        ...     ${test_list}=  Evaluate   ${rate_list[${i}]}/1e+${decimals_list[${j}]}
        ...     Calculate Rate
        ...     AND
        ...     Should Be Equal As Numbers      ${rate_list[${i}]}      ${currentPrice_list[${j}]}
#        ...     Run Keywords
##        ...     ${currentPrice_list[${j}]}=  Evaluate   ${currentPrice_list[${j}]}*${decimals_list[${j}]}
##        ...     ${test_list[${j}]}=  evaluate   1*2
#        ...     Append To List  ${test_list}    Evaluate   ${currentPrice_list[${j}]}*${decimals_list[${j}]}
#        ...     AND
#        ...     Verify Rate Between Cache And Tokens Pairs API
#        ...     AND

    END

Verify Rate Between Cache And Tokens Pairs API
    Log  'hihihaha'
#    ${cache_rate[${i}]}=   Evaluate     ${rate_list[${i}]} /  ${decimals_list[${j}]}
    Should Be Equal As Numbers      ${rate_list[${i}]}    ${currentPrice_list[${j}]}

Calculate Rate
    ${test_list}=  evaluate   1*2

















