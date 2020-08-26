*** Settings ***
Resource            ../../resources/imports.robot


*** Test Cases ***
TC01_Check API Tokens Pairs returns status code = 200
    [Documentation]    __author__ Tuyen Khuc  28/07/2020. Update 08/08/2020
    ...     To verify that API returns status code = 200.
    [Tags]    ready    regression-test    PASSED
    Create API ${url_api} Session
    Send Request API '${url_api_tokens_pairs}' With Param '' And Get The Response
    Verify Response Code Shoulde Be 200

TC02_Check API Tokens Pairs returns general info, detail all elements
    [Documentation]  To verify that API returns general info, detail all elements
    ...     1. General info: Keys, and Length
    ...     2. get data currencies from config file: ok
    ...     3. Get Detail All Elements Of Tokens Pairs: ok
    ...     4. Compare Symbol Name AddressContract Decimals Between Config File Data And Tokens Pairs API Data: ok
    ...     5. Verify Current Price Of Tokens Pairs By Refer Cache: ok
    ...     6. Verify Last Price Of Tokens Pairs By Refer Current Price: ok
    ...     7. Verify Timestamp: ok
    ...     8. Verify baseVolume: ok
    ...     9. Verify baseVolume: ok
    [Tags]    ready    regression-test    PASSED
    Create API ${url_api} Session
    Send Request API '${url_api_tokens_pairs}' With Param '' And Get The Response
    Convert Json Response To Python File
    Get Data Currencies From Config File
    Get Detail All Elements Of Tokens Pairs
    Compare Symbol Name AddressContract Decimals Between Config File Data And Tokens Pairs API Data
    Verify Current Price Of Tokens Pairs By Refer Cache
    Verify Last Price Of Tokens Pairs By Refer Current Price
    Verify Timestamp Of Tokens Pairs By Refer Current Time
    Verify BaseVoume Of Tokens Pairs
    Verify QuoteVolume Of Tokens Pairs
TC03_Check API Tokens Pairs returns 404 not found, status code 404
    [Documentation]  To verify that API returns 404 not found, status code 404
    ...     status_code = 404
    [Tags]    ready    regression-test    PASSED
    Create API ${url_api} Session
    Send Request API '${url_api_tokens_pairs_error}' With Param '' And Get The Response
    Verify 404 Page Not Found



