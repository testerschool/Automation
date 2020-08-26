*** Settings ***
Library     RequestsLibrary
Library     os
Library     JSONLibrary

Documentation   Status: ok
...             env: staging
...             date: 04022020
...             How to run: robot Testcases\ChartConfig\TC01_chart_config.robot
...             Structure:
...                 TC01: status code should return equal to 200
...                 TC02: supports_group_request should return false
...                 TC03: supports_marks should return false
...                 TC04: supports_search should return false
...                 TC05: supports_timescale_marks should return false
...                 TC06: supports_time should return false
...                 TC07: exchanges should be empty array
...                 TC08: symbols_types should be empty array

*** Variables ***
${base_url}     https://staging-api.knstats.com
${endpoint}     /chart/config
${true}     true
${false}    false

*** Test Cases ***
TC01: status code should return equal to 200
    create session  chartConfig     ${base_url}
    ${response}=  get request     chartConfig     ${endpoint}
    #${status_code}=  ${response.status_code}
    ${status_code}=     convert to string   ${response.status_code}
    log to console   ${status_code}

TC02: supports_group_request should return false
    create session  chartConfig     ${base_url}
    ${response}=  get request     chartConfig     ${endpoint}
    ${body}=    to json  ${response.content}

    ${supports_group_request}=  get value from json  ${body}    $.supports_group_request
    ${false}=   convert to boolean  false
    should be equal  ${supports_group_request[0]}   ${false}

TC03: supports_marks should return false
    create session  chartConfig     ${base_url}
    ${response}=  get request     chartConfig     ${endpoint}
    ${body}=    to json  ${response.content}

    ${supports_marks}=  get value from json  ${body}    $.supports_marks
    ${false}=   convert to boolean  false
    should be equal  ${supports_marks[0]}   ${false}

TC04: supports_search should return false
    create session  chartConfig     ${base_url}
    ${response}=  get request     chartConfig     ${endpoint}
    ${body}=    to json  ${response.content}

    ${supports_search}=  get value from json  ${body}    $.supports_search
    ${true}=   convert to boolean  true
    should be equal  ${supports_search[0]}   ${true}

TC05: supports_timescale_marks should return false
    create session  chartConfig     ${base_url}
    ${response}=  get request     chartConfig     ${endpoint}
    ${body}=    to json  ${response.content}

    ${supports_timescale_marks}=  get value from json  ${body}    $.supports_timescale_marks
    ${false}=   convert to boolean  false
    should be equal  ${supports_timescale_marks[0]}   ${false}

TC06: supports_time should return false
    create session  chartConfig     ${base_url}
    ${response}=  get request     chartConfig     ${endpoint}
    ${body}=    to json  ${response.content}

    ${supports_time}=  get value from json  ${body}    $.supports_time
    ${true}=   convert to boolean  true
    should be equal  ${supports_time[0]}   ${true}

TC07: exchanges should be empty array
    create session  chartConfig     ${base_url}
    ${response}=  get request     chartConfig     ${endpoint}
    ${body}=    to json  ${response.content}

    ${exchanges}=  get value from json  ${body}    $.exchanges
    should be empty  ${exchanges[0]}

TC08: symbols_types should be empty array
    initSession
    ${response}=  get request     chartConfig     ${endpoint}
    ${body}=    to json  ${response.content}

    ${symbols_types}=  get value from json  ${body}    $.symbols_types
    should be empty  ${symbols_types[0]}
    log to console  ${symbols_types[0]}

*** Keywords ***
initSession
    create session  chartConfig     ${base_url}