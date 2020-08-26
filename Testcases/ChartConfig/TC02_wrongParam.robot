*** Settings ***
Library     RequestsLibrary
Library     os
Library     JSONLibrary

Documentation   Status: ok
...             env: staging
...             date: 04022020
...             How to run: robot Testcases\ChartConfig\TC02_wrongParam.robot
...             Structure:
...                 TC01: status code should return equal to 200 and content là 404 page not found


*** Variables ***
${base_url}     https://staging-api.knstats.com
${endpoint}     /chart/config1
${true}     true
${false}    false

*** Test Cases ***
TC01: status code should be 404 and content should be 404 page not found
    create session  getSuppotConfig     ${base_url}
    ${response}=  get request     getSuppotConfig     ${endpoint}
    ${status_code}=  convert to string  ${response.status_code}
    log to console  ${status_code}
    ${body}=    convert to string  ${response.content}
    log to console   ${body}
    should be equal  ${status_code}   404
    should be equal  ${body}   404 page not found



