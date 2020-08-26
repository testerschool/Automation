*** Settings ***
Library     JSONLibrary
Library     os
Library     OperatingSystem
Library     Collections
Library     RequestsLibrary
#Resource    currencies.json
#Resource    ../../Env/dev/currencies.json
#Resource    ../../Env/dev/internal_currencies.json
#Library  DataDriver

*** Variables ***
${url_api}                  https://dev-api.knstats.com
${currencies}               /currencies
${internal_currencies}      /internal/currencies
${tokens_pairs}             /api/tokens/pairs



*** Test Cases ***
TC01: Read Data on DEV env from currencies.json
    Create API Session
    Send Request API '${tokens_pairs}' Response
    Verify Response Code Shoulde Be 200
    Read Config File
    Get Data of API Tokens Pairs

TC02: For loop 2d List
    ${items_currencies}=  Get Dictionary Items     ${jsondata}
    ${keys_currencies}=    get dictionary keys     ${jsondata}
    ${values_currencies}=  get dictionary values   ${jsondata}

*** Keywords ***
Get Data of API Tokens Pairs
    ${items_tp}=  Get Dictionary Items     ${jsondata}
    ${keys_tp}=  get dictionary keys  ${jsondata}
    ${tokens_pairs_length}=  Get Length  ${keys}
    Set Global Variable  ${tokens_pairs_length}    ${tokens_pairs_length}
    ${symbolList}=  Create List                                                 #array - list
    FOR     ${i}      IN RANGE     0    ${tokens_pairs_length}
    ${elementValue}=  Get From Dictionary  ${jsondata}     ${keys[${i}]}        #${jsondata} - json object - dictionary
    ${symbol}=  Get Value From Json  ${elementValue}    $.symbol
    Append To List  ${symbolList}   ${symbol[0]}
    END

Read Config File
#    ${currencies_config}=     Get File    D:\\AutomationWorkspace\\RobotFramework\\Projects\\APIExample1\\Testcases\\readJsonData\\currencies.json
#    ${currencies_config}=     Get File    D:\\AutomationWorkspace\\RobotFramework\\Projects\\APIExample1\\Env\\dev\\currencies.json
    ${currencies_config}=     Get File    D:\\AutomationWorkspace\\RobotFramework\\Projects\\APIExample1\\Env\\${env}\\currencies.json
#    Log  ${currencies_config}
    ${currencies_config_json}=  to json  ${currencies_config}
    ${data_config}=  Get Value From Json    ${currencies_config_json}    $.data
    #    Log  ${data_config[0]}
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
        Append To List  ${token_config_list}   ${symbol_config[0]}
        ${name_config}=   Get Value From Json  ${currencies_config_json}  $.data[${i}].name
        Append To List  ${name_config_list}   ${name_config[0]}
        Append To List  ${token_config_list}   ${name_config[0]}
        ${address_config}=   Get Value From Json  ${currencies_config_json}  $.data[${i}].address
        Append To List  ${address_config_list}   ${address_config[0]}
        Append To List  ${token_config_list}   ${address_config[0]}
        ${decimals_config}=   Get Value From Json  ${currencies_config_json}  $.data[${i}].decimals
        Append To List  ${decimals_config_list}   ${decimals_config[0]}
        Append To List  ${token_config_list}   ${decimals_config[0]}
    END
    Log  ${symbol_config_list}
    Log  ${name_config_list}
    Log  ${address_config_list}
    Log  ${decimals_config_list}
    Log  ${token_config_list}



Create API Session
    [Documentation]
    ...     Create a session for API
    Create Session  httprequest     ${url_api}
    set global variable  ${httprequest}    httprequest
    [Return]    ${httprequest}

Send Request API '${api_name}' Response
    ${resp}=     Get Request  ${httprequest}    ${api_name}
    Log     ${resp.content}
    ${jsondata}=  To Json     ${resp.content}
    set global variable  ${resp}    ${resp}
    set global variable  ${jsondata}    ${jsondata}
    [Return]    ${jsondata}

Verify Response Code Shoulde Be 200
    [Documentation]
    ...     Verify Response Code Shoulde Be 200
    Should Be Equal As Strings  ${resp.status_code}  200