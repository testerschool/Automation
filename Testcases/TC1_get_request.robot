*** Settings ***
Library     RequestsLibrary
Library     Collections
*** Variables ***
${base_url}     http://restapi.demoqa.com
${city}     Delhi

*** Test Cases ***
Get_weatherInfo
    create session  mysession   ${base_url}
    ${response}=   get request  mysession  /utilities/weather/city/${city}
    #response: include header, body, everything related to api
    #log to console   ${response.status_code}
    #log to console  ${response.content}
    #log to console  ${response.headers}

    #validataions
    ${status_code}=     convert to string   ${response.status_code}
    should be equal     ${status_code}     200

    ${body}=   convert to string    ${response.content}
    should contain  ${body}     Delhi

    #dictionary
    ${contentTypeValue}=    get from dictionary  ${response.headers}     Content-Type
    should be equal  ${contentTypeValue}    application/json
    log to console  ${contentTypeValue}



