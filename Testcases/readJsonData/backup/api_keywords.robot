*** Settings ***
Resource       ../../../resources/imports.robot

*** Variables ***
${source_address}       0x8fA07F46353A2B17E92645592a94a0Fc1CEb783F
${dest_address}         0x8d61ab7571b117644a52240456df66ef846cd999
@{gas_prices}            low     medium      high

*** Keywords ***
##########################################    Create and send request    ##########################################
Create API ${api_name} Session
    [Documentation]
    ...     Create a session for API
    Create Session  httprequest     ${api_name}
    set global variable  ${httprequest}    httprequest
    [Return]    ${httprequest}

Send Request API '${api_name}' With Param '${params}' And Get The Response
    ${resp}=     Get Request  ${httprequest}    ${api_name}    params=${params}
    set global variable  ${resp}    ${resp}
    [Return]    ${resp}

Send Request API Market And Get The Response
    [Documentation]
    ...     Send Request API Market And Get The Response
    ${resp}=     Get Request  ${httprequest}  ${url_api_market}
    set global variable  ${resp}    ${resp}
    [Return]    ${resp}

##########################################    Veryfi    ##########################################

                            ################## Common Keywords (Can be used for app APIs) ##################

Verify Response Code Shoulde Be 200
    [Documentation]
    ...     Verify Response Code Shoulde Be 200
    Should Be Equal As Strings  ${resp.status_code}  200

Verify Response Code Shoulde Be 404
    [Documentation]
    ...     Verify Response Code Shoulde Be 404
    Should Be Equal As Strings  ${resp.status_code}  404

Verify Response Content Shoulde Be 'page not found'
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.content}  404 page not found

Verify 404 Page Not Found
    [Documentation]
    ...     Verify Status Code Should Be 404
    ...     Verify Response Content Should Be 404 page not found
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.content}  404 page not found

Convert Json Response To Python File
    [Documentation]
    ...     Convert Json Response To Python File
    ${jsondata}=  To Json  ${resp.content}
    log    ${jsondata}
    ${pythonfile}=    evaluate    json.loads(json.dumps(${jsondata}))    json
    set global variable  ${pythonfile}    ${pythonfile}
    set global variable  ${jsondata}    ${jsondata}
    [Return]    ${jsondata}     ${pythonfile}

Check API Returns Error With Reason '${reason}' And Additional_data '${additional_data}'
    [Documentation]
    ...     Check API Returns Errors With reason and additional_data correctly
    log    ${jsondata["error"]}
    should be equal as strings  ${jsondata["error"]}     True
    log    ${jsondata["reason"]}
    should be equal as strings  ${jsondata["reason"]}     ${reason}
    log    ${jsondata["additional_data"]}
    should be equal as strings  ${jsondata["additional_data"]}     ${additional_data}

Update API Url By Replacing '${word_need_to_replace}' To '${word_replace}' In '${url_api_from_config_file}'
    [Documentation]
    ...     Update API Url By Replacing word
    ${url_afer_edit}=   Replace String       ${url_api_from_config_file}    ${word_need_to_replace}     ${word_replace}
    set global variable     ${url_afer_edit}    ${url_afer_edit}
    [Return]    ${url_afer_edit}

Get Address Of ${token_symbol} Token From Excel
    [Documentation]     To get token address from excel file when having token symbol

    Open Excel      ${excel_path_tokens_information}
    FOR   ${number_index}   IN RANGE    0   ${api_tokens_number}
        ${row}=     evaluate    ${number_index} + 1
        ${symbol_excel}=      Read Cell Data By Coordinates    ${sheet_official_reserves}   0    ${row}
        Exit For Loop If  '${symbol_excel}' == '${token_symbol}'
    END
    ${token_address}=   Read Cell Data By Coordinates     ${sheet_official_reserves}   2    ${row}
    set global variable     ${token_address}    ${token_address}
    [Return]    ${token_address}

Generate Value For Params Value, Gas Limit, Gas Price
    [Documentation]     To get data randomly for value, gas limit and gas price

    ${value}=   evaluate    '%.2f' % random.uniform(0,200)
    ${gas_limit}=   evaluate    random.randint(50000,3000000)
    ${gas_price}=   evaluate    random.choice($gas_prices)
    set global variable    ${value}     ${value}
    set global variable    ${gas_limit}     ${gas_limit}
    set global variable    ${gas_price}     ${gas_price}
    [Return]    ${value}    ${gas_limit}    ${gas_price}

Generate Value For Nonce
    ${nonce_randomed}=   evaluate    random.randint(1,300000)
    set global variable    ${nonce_randomed}     ${nonce_randomed}
    [Return]    ${nonce_randomed}

                                ################## API /currencies ##################
Check Tokens Has '${amount_reserves_src}' reserves source and '${amount_reserves_dest}' reserves dests
    [Documentation]
    ...     Check amount of reserve_source and reservve_dest of tokens
    ${reserves_src}=     set variable     ${pythonfile["data"][${token_index_1}]["reserves_src"]}
    ${length_reserves_src}=   get length   ${reserves_src}
    should be equal as numbers      ${length_reserves_src}      ${amount_reserves_src}
    FOR   ${reserve_src_index}   IN RANGE    0   ${amount_reserves_src}
       should contain     ${reserves_src_excel}    ${reserves_src[0][${reserve_src_index}]}
    END

    ${reserves_dest}=     set variable     ${pythonfile["data"][${token_index_1}]["reserves_dest"]}
    ${length_reserves_dest}=   get length   ${reserves_dest}
    should be equal as numbers      ${length_reserves_dest}      ${amount_reserves_dest}
    FOR   ${reserve_dest_index}   IN RANGE    0   ${amount_reserves_dest}
       should contain     ${reserves_dest_excel}    ${reserves_dest[0][${reserve_dest_index}]}
    END

Check Tokens Has No reserves source and No reserves dests
    [Documentation]
    ...     Check Tokens Has No reserves source and No reserves dests
    ${reserves_src}=     Get Value From Json     ${jsondata}   $..data[${token_index_1}][reserves_src]
    should be equal as strings     ${reserves_src}     []
    ${reserves_dest}=     Get Value From Json     ${jsondata}   $..data[${token_index_1}][reserves_dest]
    should be equal as strings     ${reserves_dest}     []

Check API Returns '${tokens_number}' Official Tokens The Same As Google Sheet '${token_info_sheet}' And Check Symbol, Name, Address, Deciaml, ID, Reserves_Src, Reserve_Dest In Params Returned Are Correct
    [Documentation]
    ...     Check API Returns only Official Tokens And Check Symbol, Name, Address, Deciaml, ID, Reserves_Src, Reserve_Dest In Params Returned Are Correct
    FOR   ${token_index_1}   IN RANGE    0   ${tokens_number}
       log     ${token_index_1}
       ${row}=  evaluate  ${token_index_1} + 1
       Open Excel      ${excel_path_tokens_information}
       ${symbol_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}   0    ${row}
       ${name_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}    1    ${row}
       ${address_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}    2    ${row}
       ${decimal_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}    3    ${row}
       ${id_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}    4    ${row}
       ${reserves_src_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}   5    ${row}
       ${reserves_dest_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}   6    ${row}
       set global variable  ${token_index_1}  ${token_index_1}
       set global variable  ${reserves_src_excel}  ${reserves_src_excel}
       set global variable  ${reserves_dest_excel}  ${reserves_dest_excel}
       log    ${jsondata["data"][${token_index_1}]["symbol"]}
       log    ${pythonfile["data"][${token_index_1}]["symbol"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["symbol"]}     ${symbol_excel}
       log    ${jsondata["data"][${token_index_1}]["name"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["name"]}     ${name_excel}
       log    ${pythonfile["data"][${token_index_1}]["address"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["address"]}     ${address_excel}
       log    ${pythonfile["data"][${token_index_1}]["decimals"]}
       should be equal as numbers  ${pythonfile["data"][${token_index_1}]["decimals"]}     ${decimal_excel}
       log    ${pythonfile["data"][${token_index_1}]["id"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["id"]}     ${id_excel}

       ############################## Verify production tokens ##############################
       Run keyword if     '${symbol_excel}' == 'ETH' and '${network}' == 'mainnet'   Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'WETH' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'KNC' and '${network}' == 'mainnet'   Check Tokens Has '4' reserves source and '4' reserves dests
       Run keyword if     '${symbol_excel}' == 'DAI' and '${network}' == 'mainnet'   Check Tokens Has '6' reserves source and '6' reserves dests
       Run keyword if     '${symbol_excel}' == 'OMG' and '${network}' == 'mainnet'   Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'SNT' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'ELF' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'POWR' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'MANA' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BAT' and '${network}' == 'mainnet'   Check Tokens Has '4' reserves source and '4' reserves dests
       Run keyword if     '${symbol_excel}' == 'REQ' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BQX' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'LINK' and '${network}' == 'mainnet'  Check Tokens Has '4' reserves source and '4' reserves dests
       Run keyword if     '${symbol_excel}' == 'DGX' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'IOST' and '${network}' == 'mainnet'  Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'ENJ' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BLZ' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'POLY' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'CVC' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'PAY' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BNT' and '${network}' == 'mainnet'   Check Tokens Has '3' reserves source and '3' reserves dests
       Run keyword if     '${symbol_excel}' == 'TUSD' and '${network}' == 'mainnet'  Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'LEND' and '${network}' == 'mainnet'  Check Tokens Has '3' reserves source and '3' reserves dests
       Run keyword if     '${symbol_excel}' == 'MTL' and '${network}' == 'mainnet'   Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'REP' and '${network}' == 'mainnet'   Check Tokens Has '4' reserves source and '4' reserves dests
       Run keyword if     '${symbol_excel}' == 'ZRX' and '${network}' == 'mainnet'   Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'REN' and '${network}' == 'mainnet'   Check Tokens Has '3' reserves source and '3' reserves dests
       Run keyword if     '${symbol_excel}' == 'QKC' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'MKR' and '${network}' == 'mainnet'   Check Tokens Has '3' reserves source and '3' reserves dests
       Run keyword if     '${symbol_excel}' == 'OST' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'PT' and '${network}' == 'mainnet'    Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'ABYSS' and '${network}' == 'mainnet'     Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'WBTC' and '${network}' == 'mainnet'  Check Tokens Has '4' reserves source and '4' reserves dests
       Run keyword if     '${symbol_excel}' == 'MLN' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'USDC' and '${network}' == 'mainnet'  Check Tokens Has '5' reserves source and '5' reserves dests
       Run keyword if     '${symbol_excel}' == 'EURS' and '${network}' == 'mainnet'  Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'MCO' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'PAX' and '${network}' == 'mainnet'   Check Tokens Has '3' reserves source and '3' reserves dests
       Run keyword if     '${symbol_excel}' == 'GEN' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'LRC' and '${network}' == 'mainnet'   Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'RLC' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'NPXS' and '${network}' == 'mainnet'  Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'GNO' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'MYB' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BAM' and '${network}' == 'mainnet'   Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'SPN' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'EQUAD' and '${network}' == 'mainnet'     Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'UPP' and '${network}' == 'mainnet'   Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'CND' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'USDT' and '${network}' == 'mainnet'  Check Tokens Has '4' reserves source and '4' reserves dests
       Run keyword if     '${symbol_excel}' == 'SNX' and '${network}' == 'mainnet'   Check Tokens Has '3' reserves source and '3' reserves dests
       Run keyword if     '${symbol_excel}' == 'BTU' and '${network}' == 'mainnet'   Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'TKN' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'RAE' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'SUSD' and '${network}' == 'mainnet'  Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'SPIKE' and '${network}' == 'mainnet'     Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'SAN' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'USDS' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'NEXXO' and '${network}' == 'mainnet'     Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'EKG' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'ANT' and '${network}' == 'mainnet'   Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'GDC' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'AMPL' and '${network}' == 'mainnet'  Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'TKX' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'MET' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'MFG' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'FXC' and '${network}' == 'mainnet'   Check Tokens Has No reserves source and No reserves dests
       Run keyword if     '${symbol_excel}' == 'UBT' and '${network}' == 'mainnet'   Check Tokens Has '3' reserves source and '3' reserves dests
       Run keyword if     '${symbol_excel}' == 'LOOM' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'PBTC' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'OGN' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BAND' and '${network}' == 'mainnet'  Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'RSV' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'RSR' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'KEY' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'PNK' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'GHT' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'TRYB' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == '2KEY' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'PLR' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BUSD' and '${network}' == 'mainnet'  Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'QNT' and '${network}' == 'mainnet'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'HUSD' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'PNT' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'COMP' and '${network}' == 'mainnet'  Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'BZRX' and '${network}' == 'mainnet'  Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'RENBTC' and '${network}' == 'mainnet'  Check Tokens Has No reserves source and No reserves dests

       ############################## Verify dev tokens ##############################
       Run keyword if     '${symbol_excel}' == 'KNC' and '${network}' == 'ropsten'   Check Tokens Has '5' reserves source and '5' reserves dests
       Run keyword if     '${symbol_excel}' == 'OMG' and '${network}' == 'ropsten'   Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'EOS' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'SNT' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'ELF' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'POWR' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BAT' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'REQ' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'GTO' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'RDN' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'SALT' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'BQX' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'ADX' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'AST' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'RCN' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'DAI' and '${network}' == 'ropsten'   Check Tokens Has '3' reserves source and '3' reserves dests
       Run keyword if     '${symbol_excel}' == 'LINK' and '${network}' == 'ropsten'   Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'IOST' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'STORM' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'WETH' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'WBTC' and '${network}' == 'ropsten'   Check Tokens Has '4' reserves source and '4' reserves dests
       Run keyword if     '${symbol_excel}' == 'MANA' and '${network}' == 'ropsten'   Check Tokens Has '2' reserves source and '2' reserves dests
       Run keyword if     '${symbol_excel}' == 'ZIL' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'ENG' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
       Run keyword if     '${symbol_excel}' == 'APPC' and '${network}' == 'ropsten'   Check Tokens Has '1' reserves source and '1' reserves dests
    END

                                ################## API /user_currencies ##################

Check API Returns '${tokens_number}' Tokens The Same As Google Sheet '${token_info_sheet}' And Check id, enabled, tx_required Are Correct
    [Documentation]     Check API Returns Tokens And Check id, enabled, tx_required Are Correct
    ${real_tokens_number}=  evaluate  ${tokens_number} - 1
    FOR   ${token_index_1}   IN RANGE    0   ${real_tokens_number}
        log     ${token_index_1}
        ${row}=  evaluate  ${token_index_1} + 2
        Open Excel      ${excel_path_tokens_information}
        ${id_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}   2    ${row}
        log    ${pythonfile["data"][${token_index_1}]["id"]}
        log    ${pythonfile["data"][${token_index_1}]["enabled"]}
        log    ${pythonfile["data"][${token_index_1}]["txs_required"]}
        should be equal as strings  ${pythonfile["data"][${token_index_1}]["id"]}     ${id_excel}
    END

Check API Returns '${tokens_number}' Tokens The Same As Google Sheet '${token_info_sheet}' And Check id, enabled, tx_required Are Correct With Some Tokens Are Not Aprroved
    [Documentation]
    ...     Check API Returns Tokens And Check id, enabled, tx_required Are Correct
    ${real_tokens_number}=  evaluate  ${tokens_number} - 1
    FOR   ${token_index_1}   IN RANGE    0   ${real_tokens_number}
       log     ${token_index_1}
       ${row}=  evaluate  ${token_index_1} + 2
       Open Excel      ${excel_path_tokens_information}
       ${id_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}   2    ${row}
       log    ${pythonfile["data"][${token_index_1}]["id"]}
       log    ${pythonfile["data"][${token_index_1}]["enabled"]}
       log    ${pythonfile["data"][${token_index_1}]["txs_required"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["id"]}     ${id_excel}
       log  ${token_address_KNC}
       log  ${id_excel}
       Run keyword if     '${id_excel}' == '${token_address_KNC}'  should be equal as strings  ${pythonfile["data"][${token_index_1}]["enabled"]}     True
       ...     ELSE
       ...     Should be equal as strings  ${pythonfile["data"][${token_index_1}]["enabled"]}     False
       Run keyword if     '${id_excel}' == '${token_address_KNC}'  should be equal as strings  ${pythonfile["data"][${token_index_1}]["txs_required"]}     0
       ...     ELSE
       ...     Should be equal as strings  ${pythonfile["data"][${token_index_1}]["txs_required"]}     1
    END

                            ################## API /enable_data ##################

Check API Returns Correct User Wallet Address Is '${wallet_address}', Token Address Is '${token_address}', Data Not Empty, Value Is '${value}', GasPrice Not Empty, Nonce Is '${nonce}' And GasLimit Is '${gas_limit}'
    [Documentation]
    ...     Check API Returns Correct User Wallet Address, Token Address, Data, Value, GasPrice, Nonce And GasLimit
    should be equal as strings  ${pythonfile["data"]["from"]}     ${wallet_address}
    should be equal as strings  ${pythonfile["data"]["to"]}     ${token_address}
    should not be equal as strings  ${pythonfile["data"]["data"]}    ${EMPTY}
    should be equal as strings  ${pythonfile["data"]["value"]}     ${value}
    should not be equal as strings  ${pythonfile["data"]["gasPrice"]}    ${EMPTY}
    should be equal as strings  ${pythonfile["data"]["nonce"]}     ${nonce}
    should be equal as strings   ${pythonfile["data"]["gasLimit"]}     ${gas_limit}

                            ################## API /trade_data ##################

Check API Returns Correct User Wallet Address Is '${wallet_address}', Contract Address Is Correct, Data Not Empty, Value Is '${value}', GasPrice Not Empty, Nonce Is '${nonce}' And GasLimit Is '${gas_limit}'
    [Documentation]
    ...     Check API Returns Correct User Wallet Address, Contract Address, Data, Value, GasPrice, Nonce And GasLimit
    ${value_hex}=   set variable   ${pythonfile["data"][0]["value"]}
    ${value_api}=   Convert To Number   ${value_hex}
    ${value_api_correct}=   run keyword if  '${value_api}' > 100
    ...     evaluate   ${value_api}/10e+17
    ...     ELSE
    ...     set variable    ${value}
    ${nonce_hex}=   set variable   ${pythonfile["data"][0]["nonce"]}
    ${nonce_api}=   Convert To Number   ${nonce_hex}
    should be equal as strings  ${pythonfile["data"][0]["from"]}     ${wallet_address}
    should be equal as strings      ${pythonfile["data"][0]["to"]}     ${kyber_network_proxy_contract}
    should not be equal as strings  ${pythonfile["data"][0]["data"]}    ${EMPTY}
    run keyword if  '${value_hex}' != '0x0'
    ...     should be equal as numbers     ${value_api_correct}    ${value}
    ...     ELSE
    ...     should be equal as numbers      ${value_api_correct}     0
    should not be equal as strings  ${pythonfile["data"][0]["gasPrice"]}    ${EMPTY}
    Run keyword if     '${nonce}' == '${EMPTY}'
    ...     should not be equal as strings  ${pythonfile["data"][0]["nonce"]}     ${EMPTY}
    ...     ELSE
    ...     should be equal as numbers  ${nonce_api}    ${nonce}

                            ################## API /market ##################

Check API Returns '${tokens_number}' Official Tokens The Same As Google Sheet '${token_info_sheet}' And Check Params Value Returned Are Correct
    [Documentation]
    ...     Check API Returns enough Tokens And Check Params Value Returned Are Correct:
    ...     timestamp
    ...     quote_symbol
    ...     quote_name
    ...     quote_decimals
    ...     quote_address
    ...     base_symbol
    ...     base_name
    ...     base_decimals
    ...     base_address
    ...     past_24h_high
    ...     past_24h_low
    ...     usd_24h_volume
    ...     eth_24h_volume
    ...     token_24h_volume
    ...     current_bid
    ...     current_ask
    ...     last_traded
    ...     pair

    Web - Open Tracker Page
    Click Tokens Menu

    Send Request API Market And Get The Response
    Verify Response Code Shoulde Be 200
    Convert Json Response To Python File

    ###### Verify time_stamp ######
    log    ${jsondata["data"][0]["timestamp"]}
    ${date}=    Get Current Date
    ${epoch_date}=      Convert Date        ${date}     epoch
    ${minus_date}=      evaluate  ${epoch_date} - ${jsondata["data"][0]["timestamp"]}
    should be true      ${minus_date} < 5

    FOR   ${token_index_1}   IN RANGE    1   ${tokens_number}
       log     ${token_index_1}
       ${row}=  evaluate  ${token_index_1} + 2
       Open Excel      ${excel_path_tokens_information}
       ${symbol_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}   0    ${row}
       ${name_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}    1    ${row}
       ${address_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}    2    ${row}
       ${decimal_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}    3    ${row}
       ${id_excel}=      Read Cell Data By Coordinates    ${token_info_sheet}    4    ${row}

    ###### Verify quote_symbol, quote_name, quote_decimals, quote_address ######
       log    ${jsondata["data"][${token_index_1}]["quote_symbol"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["quote_symbol"]}     ETH
       log    ${jsondata["data"][${token_index_1}]["quote_name"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["quote_name"]}     Ethereum
       log    ${pythonfile["data"][${token_index_1}]["quote_decimals"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["quote_decimals"]}     18
       log    ${pythonfile["data"][${token_index_1}]["quote_address"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["quote_address"]}     0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

    ###### Verify base_symbol, base_name, base_decimals, base_address ######
       log    ${jsondata["data"][${token_index_1}]["base_symbol"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["base_symbol"]}     ${symbol_excel}
       log    ${jsondata["data"][${token_index_1}]["base_name"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["base_name"]}     ${name_excel}
       log    ${pythonfile["data"][${token_index_1}]["base_decimals"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["base_decimals"]}     ${decimal_excel}
       log    ${pythonfile["data"][${token_index_1}]["base_address"]}
       should be equal as strings  ${pythonfile["data"][${token_index_1}]["base_address"]}     ${address_excel}

    ###### Verify usd_24h_volume, eth_24h_volume ######
       ${token_lowser_case}=      Convert To Lowercase     ${symbol_excel}
       ${value}   Web - get text on element   //*[contains(@src,'/tokens/${token_lowser_case}')]/../..//td[3]
       ${usd_24h_volume}=      Get Substring   ${value}    1
       ${usd_24h_volume_no_comma}=  Replace String  ${usd_24h_volume}  ,  ${EMPTY}
       ${usd_24h_volume_integer}=      convert to number  ${usd_24h_volume_no_comma}
       ${minus_usd_24h_volume}=       Evaluate    ${usd_24h_volume_integer} - ${pythonfile["data"][${token_index_1}]["usd_24h_volume"]}
       ${abs_minus_usd_24h_volume}=       Evaluate    abs(${minus_usd_24h_volume})
       log      ${pythonfile["data"][${token_index_1}]["usd_24h_volume"]}
       log      ${usd_24h_volume}
       ${percentage_usd_24h_volume}=   Run keyword if   ${usd_24h_volume_integer} != 0.00
       ...  Evaluate    (${abs_minus_usd_24h_volume}/${pythonfile["data"][${token_index_1}]["usd_24h_volume"]}) * 100
       ...  ELSE    set variable    0
       Run keyword if   ${percentage_usd_24h_volume} != 0 and ${usd_24h_volume_integer} > 5000
       ...  should be true      ${percentage_usd_24h_volume} < 15
       ...  ELSE IF     ${percentage_usd_24h_volume} != 0 and ${usd_24h_volume_integer} < 5000
       ...  should be true      ${abs_minus_usd_24h_volume} < 1000
       ...  ELSE IF     ${percentage_usd_24h_volume} != 0 and ${usd_24h_volume_integer} == 5000
       ...  should be true      ${abs_minus_usd_24h_volume} < 1000
       ...  ELSE
       ...  should be true      ${percentage_usd_24h_volume} == ${pythonfile["data"][${token_index_1}]["usd_24h_volume"]}

       Get ETH 24h Volume Of Token '${symbol_excel}'
       ${value}   Web - get text on element   //*[contains(@src,'/tokens/${token_lowser_case}')]/../..//td[4]
       ${eth_24h_volume}=      Get Substring   ${value}    1
       ${eth_24h_volume_no_comma}=  Replace String  ${value}  ,  ${EMPTY}
       ${eth_24h_volume_integer}=      convert to number  ${eth_24h_volume_no_comma}
       ${minus_eth_24h_volume}=       Evaluate    ${eth_24h_volume_integer} - ${pythonfile["data"][${token_index_1}]["eth_24h_volume"]}
       ${abs_minus_eth_24h_volume}=       Evaluate    abs(${minus_eth_24h_volume})
       log  ${pythonfile["data"][${token_index_1}]["eth_24h_volume"]}
       ${percentage_eth_24h_volume}=   Run keyword if   ${eth_24h_volume_integer} != 0.00
       ...  Evaluate    (${abs_minus_eth_24h_volume}/${pythonfile["data"][${token_index_1}]["eth_24h_volume"]}) * 100
       ...  ELSE    set variable    0
       Run keyword if   ${percentage_eth_24h_volume} != 0 and ${eth_24h_volume_integer} > 10
       ...  should be true      ${percentage_eth_24h_volume} < 15
       ...  ELSE IF     ${percentage_eth_24h_volume} != 0 and ${eth_24h_volume_integer} < 10
       ...  should be true      ${abs_minus_eth_24h_volume} < 3
       ...  ELSE IF     ${percentage_eth_24h_volume} != 0 and ${eth_24h_volume_integer} == 10
       ...  should be true      ${abs_minus_eth_24h_volume} < 3
       ...  ELSE
       ...  should be true      ${percentage_eth_24h_volume} == ${pythonfile["data"][${token_index_1}]["eth_24h_volume"]}

       ###### Verify past_24h_high, past_24h_low, usd_24h_volume, eth_24h_volume, token_24h_volume, current_bid, current_ask, last_traded ######
       Run keyword if     '${symbol_excel}' == 'IOST' or '${symbol_excel}' == 'MTL' or '${symbol_excel}' == 'EURS' or '${symbol_excel}' == 'NPXS'
       ...     Verify past_24h_high is 0, past_24h_low is 0, token_24h_volume is 0, current_bid is 0, current_ask is 0 Of ${token_index_1}
       ...     ELSE IF  '${symbol_excel}' == 'PT'
       ...     Verify past_24h_high is 1, past_24h_low is 1, token_24h_volume is 1, current_bid is 1, current_ask is 0 Of ${token_index_1}
       ...     ELSE IF  '${symbol_excel}' == 'GEN'
       ...     Verify past_24h_high is 1, past_24h_low is 1, token_24h_volume is 1, current_bid is 0, current_ask is 1 Of ${token_index_1}
       ...     ELSE IF  '${symbol_excel}' == 'BTU'
       ...     Verify past_24h_high is 0, past_24h_low is 0, token_24h_volume is 0, current_bid is 1, current_ask is 0 Of ${token_index_1}
       ...     ELSE IF  '${value}' == 0
       ...     Verify usd_24h_volume is 0, eth_24h_volume is 0, token_24h_volume is 0 Of ${token_index_1}
       ...     ELSE IF  '${value}' != 0
       ...     Verify usd_24h_volume is 1, eth_24h_volume is 1, token_24h_volume is 1 Of ${token_index_1}
       ...     ELSE
       ...     Check past_24h_high is 1, past_24h_low is 1, current_bid is 1, current_ask is 1 Of ${token_index_1}

    ##### Verify pair ######
       should be equal as strings      ${pythonfile["data"][${token_index_1}]["pair"]}    ETH_${symbol_excel}
    END

Verify past_24h_high is ${past_24h_high}, past_24h_low is ${past_24h_low}, token_24h_volume is ${token_24h_volume}, current_bid is ${current_bid}, current_ask is ${current_ask} Of ${token_index}
    [Documentation]
    ...     Verify value
    run keyword if      ${past_24h_high}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["past_24h_high"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["past_24h_high"]}     0
    run keyword if      ${past_24h_low}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["past_24h_low"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["past_24h_low"]}     0
    run keyword if      ${token_24h_volume}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["token_24h_volume"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["token_24h_volume"]}     0
     run keyword if      ${current_bid}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["current_bid"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["current_bid"]}     0
    run keyword if      ${current_ask}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["current_ask"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["current_ask"]}     0

Check past_24h_high is ${past_24h_high}, past_24h_low is ${past_24h_low}, current_bid is ${current_bid}, current_ask is ${current_ask} Of ${token_index}
    [Documentation]
    ...     Verify value
    run keyword if      ${past_24h_high}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["past_24h_high"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["past_24h_high"]}     0
    run keyword if      ${past_24h_low}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["past_24h_low"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["past_24h_low"]}     0
#    run keyword if      ${token_24h_volume}==0
#    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["token_24h_volume"]}     0
#    ...     ELSE
#    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["token_24h_volume"]}     0
     run keyword if      ${current_bid}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["current_bid"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["current_bid"]}     0
    run keyword if      ${current_ask}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["current_ask"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["current_ask"]}     0

Verify usd_24h_volume is ${usd_24h_volume}, eth_24h_volume is ${eth_24h_volume}, token_24h_volume is ${token_24h_volume} Of ${token_index}
    [Documentation]
    ...     Verify value
    run keyword if      ${usd_24h_volume}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["usd_24h_volume"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["usd_24h_volume"]}     0
    run keyword if      ${eth_24h_volume}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["eth_24h_volume"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["eth_24h_volume"]}     0
    run keyword if      ${token_24h_volume}==0
    ...     should be equal as strings  ${pythonfile["data"][${token_index}]["token_24h_volume"]}     0
    ...     ELSE
    ...     should not be equal as strings  ${pythonfile["data"][${token_index}]["token_24h_volume"]}     0

                        ################## API /buy_rate and /sell_rate##################

Calculate Source Amount With Dest Amount Is '${dest_amount}'
    [Documentation]
    ...     Calculate Source Amount With Specific Dest Amount
    ${source_amount}=   evaluate    ${dest_amount}*${expected_rate}
    set global variable     ${source_amount}    ${source_amount}

Calculate Dest Amount With Source Amount Is '${source_amount}'
    [Documentation]
    ...     Calculate Dest Amount With Specific Source Amount
    ${dest_amount}=   evaluate    ${source_amount}*${expected_rate}
    set global variable     ${dest_amount}    ${dest_amount}

Verify Source Amount Returned Is '${source_amount_expected}'
    ${minus}=      evaluate    (${source_amount} - ${source_amount_expected})
    ${percentage}=  evaluate    ${minus}/${source_amount_expected}
    ${percentage_absolute}=  evaluate   abs(${percentage})
    should be true      ${percentage_absolute} < 0.05

Verify Dest Amount Returned Is '${dest_amount_expected}'
    ${minus}=      evaluate    (${dest_amount} - ${dest_amount_expected})
    ${percentage}=  evaluate    ${minus}/${dest_amount_expected}
    ${percentage_absolute}=  evaluate   abs(${percentage})
    should be true      ${percentage_absolute} < 0.05

Check API Returns src_id is '${src_id}', dst_id is '${dst_id}', dst_qty is '${dst_qty}' and src_qty is correct In Object '${object_number}'
    [Documentation]
    ...     Check API Returns both Official And Unofficial Tokens And Check Symbol, Name, Address, Deciaml, ID, Reserves_Src, Reserve_Dest In Params Returned Are Correct
    log    ${jsondata["data"][${object_number}]["src_id"]}
    should be equal as strings  ${jsondata["data"][${object_number}]["src_id"]}   ${src_id}
    log    ${jsondata["data"][${object_number}]["dst_id"]}
    should be equal as strings  ${jsondata["data"][${object_number}]["dst_id"]}   ${dst_id}
    ${dest_qty_list}=      set variable     ${jsondata["data"][${object_number}]["dst_qty"]}
    should be equal as strings     ${jsondata["data"][${object_number}]["dst_qty"]}     ${dst_qty}
    ${src_qty}=     Get Value From Json     ${jsondata}   $..data[${object_number}][src_qty]
    ${src_qty}    Set Variable    ${src_qty[0][0]}
    Verify Source Amount Returned Is '${src_qty}'

Check API Returns src_id is '${src_id}', dst_id is '${dst_id}', src_qty is '${src_qty}' and dest_qty is correct In Object '${object_number}'
    [Documentation]
    ...     Check API Returns both Official And Unofficial Tokens And Check Symbol, Name, Address, Deciaml, ID, Reserves_Src, Reserve_Dest In Params Returned Are Correct
    log    ${jsondata["data"][${object_number}]["src_id"]}
    should be equal as strings  ${jsondata["data"][${object_number}]["src_id"]}   ${src_id}
    log    ${jsondata["data"][${object_number}]["dst_id"]}
    should be equal as strings  ${jsondata["data"][${object_number}]["dst_id"]}   ${dst_id}
    ${source_qty_list}=      set variable     ${jsondata["data"][${object_number}]["src_qty"]}
    should be equal as strings     ${jsondata["data"][${object_number}]["src_qty"]}     ${src_qty}
    ${dest_qty}=     Get Value From Json     ${jsondata}   $..data[${object_number}][dst_qty]
    ${dest_qty}    Set Variable    ${dest_qty[0][0]}
    Verify Dest Amount Returned Is '${dest_qty}'

Check API Returns '${number_src_qty}' src_qty and '${number_dst_qty}' dst_qty In Object '${object_number}'
    ${src_qty_list}=      set variable     ${jsondata["data"][${object_number}]["src_qty"]}
    ${src_qty_list_length}=  Get length   ${src_qty_list}
    should be equal as strings     ${src_qty_list_length}     ${number_src_qty}
    ${dest_qty_list}=      set variable     ${jsondata["data"][${object_number}]["dst_qty"]}
    ${dest_qty_list_length}=  Get length   ${dest_qty_list}
    should be equal as strings     ${dest_qty_list_length}     ${number_dst_qty}

                                ################## API /gasLimitConfig ##################

Verify API Returns Correct Number Of Tokens With Gas Limit As On Excel Sheet
     FOR   ${token_index}   IN RANGE    0   ${api_tokens_number}
        ${row}=  evaluate  ${token_index} + 1
        Open Excel      ${excel_path_tokens_information}

        ${symbol_excel}=      Read Cell Data By Coordinates    ${sheet_official_reserves}   0    ${row}
        ${address_excel}=      Read Cell Data By Coordinates    ${sheet_official_reserves}    2    ${row}
        ${swapGasLimit_excel}=      Read Cell Data By Coordinates    ${sheet_official_reserves}    7    ${row}
        ${approveGasLimit_excel}=      Read Cell Data By Coordinates    ${sheet_official_reserves}    8    ${row}

        should be equal as strings  ${pythonfile["data"][${token_index}]["symbol"]}     ${symbol_excel}
        should be equal as strings  ${pythonfile["data"][${token_index}]["address"]}     ${address_excel}
        should be equal as numbers  ${pythonfile["data"][${token_index}]["swapGasLimit"]}     ${swapGasLimit_excel}
        should be equal as numbers  ${pythonfile["data"][${token_index}]["approveGasLimit"]}     ${approveGasLimit_excel}
    END

################## Trade_Log ######################

Verify Trade Log Returns Five Trades
    [Documentation]
    ...     1. Get Data From Json Variable
    ...     2. Compare Trade_Log api quatity response to 5
    ...     3. Get Detail Five Trades
    ${data}=  Get Value From Json    ${jsondata}    $.data
    Set Global Variable     ${data}     ${data}
    ${trade_log_length}=  Get Length   ${data[0]}
    Set Global Variable     ${trade_log_length}     ${trade_log_length}
    Should Be Equal As Strings    ${trade_log_length}      5
    Detail Five Trades

Detail Five Trades
    [Documentation]
    ...     1. Get each param timestamp,txHash,src,dest,actualSrc,actualDest
    ${trade_log_timestamp}=  Get Value From Json  ${jsondata}    $.timestamp
    Set Global Variable     ${trade_log_timestamp}  ${trade_log_timestamp}
    FOR     ${i}      IN RANGE  0   ${trade_log_length}
        ${timestamp}=  Get Value From Json  ${jsondata}    $.data[${i}].timestamp
        ${delta}=   Evaluate     ${trade_log_timestamp[0]} - ${timestamp[0]}
        Run Keyword If  '${network}' == 'mainnet'  Should Be True  ${delta} < 600  #second
        Run Keyword If  '${network}' == 'ropsten'  Should Be True  ${delta} < 10000  #second
        ${txHash}=  Get Value From Json  ${jsondata}    $.data[${i}].txHash
        ${src}=  Get Value From Json  ${jsondata}    $.data[${i}].src
        ${dest}=  Get Value From Json  ${jsondata}    $.data[${i}].dest
        ${actualSrc}=  Get Value From Json  ${jsondata}    $.data[${i}].actualSrc
        ${actualDest}=  Get Value From Json  ${jsondata}    $.data[${i}].actualDest
        Should Not Be Empty  ${txHash[0]}
        Should Not Be Empty  ${src[0]}
        Should Not Be Empty  ${dest[0]}
        Should Not Be Equal As Numbers  ${actualSrc[0]}    0
        Should Not Be Equal As Numbers  ${actualDest[0]}   0
    END

################## Api/Tokens/Pairs ######################

Get Data Currencies From Config File
    [Documentation]
    ...     1. Get file config data into a variable
    ...     2. Convert a variable above into config json
    ...     3. Get data value
    ...     4. Create list related with each param(symbol, name, address, decimals) of config json
    ...     5. For loop
    ...         5.1 Get each param (symbol, name, address, decimals) of config json
    ...         5.2 Append to related list
    ${currencies_config}=     Get File    D:\\AutomationWorkspace\\RobotFramework\\Projects\\user-dashboard\\user-dashboard-robot\\resources\\configs\\testing_environment\\${env}\\currencies.json
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
    set global variable  ${quoteVolume_list}  ${quoteVolume_list}

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

Verify Current Price Of Tokens Pairs By Refer Cache
    [Documentation]
    ...     1. Create Cache session, then get response with cache session
    ...     2. Get Rate Tokens from cache: all tokens
    ...     3. Compare Symbol Data Between Tokens Pairs And Cache: all tokens
     Create API ${url_cache} Session
     Send Request API '${url_cache_rate}' With Param '' And Get The Response
     Convert Json Response To Python File
     Get Rate Tokens From Cache
     Compare Symbol Data Between Tokens Pairs And Cache

Get Rate Tokens From Cache
    [Documentation]
    ...     1. get data cache from jsondata
    ...     2. get length of data cache
    ...     3. Create source_list, dest_list, rate_list
    ...     4. get source,dest, rate cache then append them to  source_list,dest_list,rate_list
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
    [Documentation]
    ...     1. Create currentPrice is zero list
    ...     2. FOR loop
    ...       2.1 Verify If Symbol Tokens Pairs Equal To Source Cache
    ${currentPrice_is_zero_list}=  Create List
    Set Global Variable     ${currentPrice_is_zero_list}    ${currentPrice_is_zero_list}
    ${pumping_tokens_list}=  Create List
    Set Global Variable     ${pumping_tokens_list}    ${pumping_tokens_list}

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
    Log     ${rate_cache_num_list}
    END

    Log  ${currentPrice_is_zero_list}
    Log  ${pumping_tokens_list}

Verify If Symbol Tokens Pairs Equal To Source Cache
    [Documentation]
    ...     1. FOR loop
    ...         1.1. Check if '${symbol_list[${i}]}' == '${source_list[${j}]}' and '${dest_list[${j}]}' == 'ETH'
    ...             1.1.1. Convert Rate Cache From Gwei To Number Between '${decimals_list[${i}]}' And '${rate_list[${j}]}'
    ...             1.1.2. Calculate Percentage Between Rate Cache '${currentPrice_list[${i}]}' And CurrentPrice Tokens Pairs '${rate_cache_num_list[0]}'
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

Convert Rate Cache From Gwei To Number Between '${pairs_decimals}' And '${rate_cache_gwei}'
    [Documentation]
    ...     1. Convert Rate Cache From Gwei To Number Between '${pairs_decimals}' And '${rate_cache_gwei}'
    ...     2. Append to list
    ${pairs_decimals}=  evaluate  ${pairs_decimals} - 1
    ${rate_cache_num}=  evaluate   (${rate_cache_gwei}/(10e+17))
    Set Global Variable  ${rate_cache_num}  ${rate_cache_num}
    Log     ${rate_cache_num}
    Append To List  ${rate_cache_num_list}   ${rate_cache_num}
    Log     ${rate_cache_num_list}

Calculate Percentage Between Rate Cache '${currentPrice_pairs}' And CurrentPrice Tokens Pairs '${rate_cache_num_list[0]}'
    [Documentation]
    ...     if '${currentPrice_pairs}' != '0'    Get Rate Percentage Between Rate Cache '${currentPrice_pairs}' And CurrentPrice Tokens Pairs '${rate_cache_num}'
    ...     else IF  '${currentPrice_pairs}' == '0'     Get List Tokens Of Tokens Pairs Has CurrentPrice Equal To 0
    Run keyword if  '${currentPrice_pairs}' != '0'    Get Rate Percentage Between Rate Cache '${currentPrice_pairs}' And CurrentPrice Tokens Pairs '${rate_cache_num}'
    ...  ELSE IF  '${currentPrice_pairs}' == '0'     Get List Tokens Of Tokens Pairs Has CurrentPrice Equal To 0

Get Rate Percentage Between Rate Cache '${currentPrice_pairs}' And CurrentPrice Tokens Pairs '${rate_cache_num}'
    [Documentation]
    ...     1. Get Rate percentage Between Rate Cache '${currentPrice_pairs}' And CurrentPrice Tokens Pairs '${rate_cache_num}'
    ...     2. rate percentage should <= 0.005
    ...     3. Append to list
    ${rate_percentage}=     evaluate    (${rate_cache_num}-${currentPrice_pairs})/${currentPrice_pairs}
    Set Global Variable  ${rate_percentage}  ${rate_percentage}
    Log     ${rate_percentage}

    Run Keyword If  ${rate_percentage} > 0.05  Get List Pumping Tokens
    ...     ELSE IF  ${rate_percentage} <= 0.05     Should Be True  ${rate_percentage} <= 0.05

#    Should Be True  ${rate_percentage} <= 0.05
    Append To List  ${rate_percentage_list}   ${rate_percentage}
    Log     ${rate_percentage_list}

Get List Pumping Tokens
    Log  ${i}
    Append To List  ${pumping_tokens_list}  ${symbol_list[${i}]}
    Log  ${pumping_tokens_list}
Get List Tokens Of Tokens Pairs Has CurrentPrice Equal To 0
    [Documentation]
    ...     1. Get list tokens that has currentPrice is zero
    Log  ${i}
    Append To List  ${currentPrice_is_zero_list}    ${symbol_list[${i}]}
    Log  ${currentPrice_is_zero_list}

Verify Last Price Of Tokens Pairs By Refer Current Price
    [Documentation]
    ...     1. create 3 lists:  ${good_liquidity_tokens_list},${bad_liquidity_tokens_list},${lastPrice_is_zero_list}
    ...     2. FOR loop
    ...         2.1 Calculate Percentage Between Current Price '${currentPrice_list[${i}]}' And Last Price '${lastPrice_list[${i}]}' Of Tokens Pairs
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
    [Documentation]
    ...     1. Calculate minus between ${currentPrice} and ${lastPrice}
    ...     2.1 if '${currentPrice}' != '0'     Get Percentage Between Current Price '${currentPrice}' And Last Price '${lastPrice}' Of Tokens Pairs
    ...     2.2 if  '${currentPrice}' == '0'     Get List Tokens Of Tokens Pairs Has LastPrice Equal To 0
    ${minus}=  Evaluate  (${currentPrice} - ${lastPrice})
    Set Global Variable     ${minus}    ${minus}
    Log  ${currentPrice}
    Log  ${lastPrice}
    Run Keyword If  '${currentPrice}' != '0'     Get Percentage Between Current Price '${currentPrice}' And Last Price '${lastPrice}' Of Tokens Pairs
    ...     ELSE IF  '${currentPrice}' == '0'     Get List Tokens Of Tokens Pairs Has LastPrice Equal To 0

Get Percentage Between Current Price '${currentPrice}' And Last Price '${lastPrice}' Of Tokens Pairs
    [Documentation]
    ...     1. Calculate percentage between currentPrice and lastPrice
    ...     2.1 if ((${current_last_price_percentage} > 0 and ${current_last_price_percentage} <= 0.01) or (${current_last_price_percentage} < 0 and ${current_last_price_percentage} >= -0.01))  Get List Of Good Liquidity Tokens
    ...     2.2 if  ((${current_last_price_percentage} > 0.01 and ${current_last_price_percentage} <= 0.1) or (${current_last_price_percentage} < -0.01 and ${current_last_price_percentage} >= -0.1))  Get List Of Bad Liquidity Tokens
    ${current_last_price_percentage}=  Evaluate  (${minus}/${currentPrice})
    Log  ${current_last_price_percentage}
    Run Keyword If  ((${current_last_price_percentage} > 0 and ${current_last_price_percentage} <= 0.01) or (${current_last_price_percentage} < 0 and ${current_last_price_percentage} >= -0.01))  Get List Of Good Liquidity Tokens
    ...     ELSE IF  ((${current_last_price_percentage} > 0.01 and ${current_last_price_percentage} <= 0.1) or (${current_last_price_percentage} < -0.01 and ${current_last_price_percentage} >= -0.1))  Get List Of Bad Liquidity Tokens

Get List Tokens Of Tokens Pairs Has LastPrice Equal To 0
    [Documentation]
    ...     1. add symbol of token has lastPrice =0 to list
    Log  ${i}
    Append To List  ${lastPrice_is_zero_list}    ${symbol_list[${i}]}
    Log  ${lastPrice_is_zero_list}

Get List Of Good Liquidity Tokens
    [Documentation]
    ...     1. add symbol of token has lastPrice ~ currentPrice to list
    Log  ${i}
    Append To List  ${good_liquidity_tokens_list}    ${symbol_list[${i}]}
Get List Of Bad Liquidity Tokens
    [Documentation]
    ...     1. add symbol of token has   (currentPrice-lastPrice)/currentPrice to list
    Log  ${i}
    Append To List  ${bad_liquidity_tokens_list}    ${symbol_list[${i}]}

Verify Timestamp Of Tokens Pairs By Refer Current Time
    [Documentation]
    ...     1. Get Current Time In Epoch
    ...     2. For loop
    ...         2.1 Set Global Variable  ${i}  ${i}
    ...         2.2 Get Minus Between Current Time And Timestamp '${lastTimestamp_list[${i}]}' From API
    ${out_of_date_tokens_list}=   Create List
    Set Global Variable  ${out_of_date_tokens_list}     ${out_of_date_tokens_list}
    Get Current Time In Epoch

    FOR  ${i}   IN RANGE    ${tokens_pairs_length}
    Set Global Variable  ${i}  ${i}
    Log  ${symbol_list[${i}]}
    Get Minus Between Current Time And Timestamp '${lastTimestamp_list[${i}]}' From API
    END
    Log  ${out_of_date_tokens_list}

Get Current Time In Epoch
    [Documentation]
    ...     1. Get Current Time
    ...     2. Convert Date to epoch (second)
    ${currentDate}=  Get Current Date
    Log  ${currentDate}
    ${currentDateInEpoch}=  Convert Date  ${currentDate}    epoch
    Set Global Variable  ${currentDateInEpoch}  ${currentDateInEpoch}
    Log  ${currentDateInEpoch}

Get Minus Between Current Time And Timestamp '${timestamp}' From API
    [Documentation]
    ...     1. Get minus_timestamp between ${currentDateInEpoch} and  ${timestamp}
    ...     2.1 if ${minus_timestamp} > 600  Get List Out Of Date Tokens
    ...     2.2 else Should Be True  ${minus_timestamp} < 600
    ${minus_timestamp}=  Evaluate  ${currentDateInEpoch} - ${timestamp}
    Log  ${minus_timestamp}
    Log  ${timestamp}
    Log  ${currentDateInEpoch}
    Run Keyword If  ${minus_timestamp} > 600  Get List Out Of Date Tokens
    ...  ELSE  Should Be True  ${minus_timestamp} < 600

Get List Out Of Date Tokens
    [Documentation]
    ...     1. add symbol of token has   out of date (timestamp is very small) to list
    Log  ${i}
    Append To List  ${out_of_date_tokens_list}  ${symbol_list[${i}]}

Verify BaseVoume Of Tokens Pairs
    [Documentation]
    ...     1. verify baseVolume >=0
    FOR  ${i}   IN RANGE    ${tokens_pairs_length}
        Should Be True  ${baseVolume_list[${i}]} >= 0
    END

Verify QuoteVolume Of Tokens Pairs
    [Documentation]
    ...     1. verify baseVolume >=0
    FOR  ${i}   IN RANGE    ${tokens_pairs_length}
        Should Be True  ${quoteVolume_list[${i}]} >= 0
    END

################## Ended: Api/Tokens/Pairs ######################

Verify API Transfer Data Return Correct ${src_add}, ${dst_add}, ${value}, ${gasLimit}, ${token_address}, Gas Price, Data And Nonce Are Not Empty
    should be equal as strings     ${pythonfile["data"]["from"]}   ${src_add}

    ${value_hex}=   set variable   ${pythonfile["data"]["value"]}
    ${value_api}=   Convert To Number   ${value_hex}
    ${value_api_correct}=   run keyword if  '${value_api}' > 100
    ...     evaluate   ${value_api}/10e+17
    ...     ELSE
    ...     set variable    ${value}

    ${data_api}=    set variable    ${pythonfile["data"]["data"]}

    run keyword if  '${data_api}' == '0x'
    ...     Run Keywords
    ...     should be equal as numbers     ${value_api_correct}    ${value}
    ...     AND     should be equal as strings     ${pythonfile["data"]["to"]}      ${dst_add}
    ...     ELSE
    ...     Run Keywords
    ...     should be equal as numbers      ${value_api_correct}     0
    ...     AND     should not be empty            ${data_api}
    ...     AND     should be equal as strings     ${pythonfile["data"]["to"]}      ${token_address}

    ${gas_price_hex}=   set variable   ${pythonfile["data"]["gasPrice"]}
    ${gas_price_api}=   Convert To Number    ${gas_price_hex}
    ${gas_price_api_correct}=   evaluate        ${gas_price_api} / 10e+8
    should be true     ${gas_price_api_correct} > 0

    ${gas_limit_hex}=   set variable   ${pythonfile["data"]["gasLimit"]}
    ${gas_limit_api}=   Convert To Number    ${gas_limit_hex}
    should be equal as numbers     ${gas_limit_api}       ${gasLimit}

    should not be empty    ${pythonfile["data"]["nonce"]}

                                        ################## Cache API ##################
Get Gas Price ${gas_price} From Cache
    Create API ${url_cache} Session
    Send Request API '${url_cache_gasPrice}' With Param '' And Get The Response
    Convert Json Response To Python File For Cache
    ${gas_price}=    set variable    ${jsondata_cache["data"]["${gas_price}"]}
    set global variable    ${gas_price}      ${gas_price}
    [Return]    ${gas_price}

