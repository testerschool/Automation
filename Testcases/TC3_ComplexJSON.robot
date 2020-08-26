*** Settings ***
Library  JSONLibrary
Library  os
Library  Collections
Library  RequestsLibrary
*** Variables ***
${base_url}     https://restcountries.eu

*** Test Cases ***
Get_countryInfo
    create session  mysession   ${base_url}
    ${response}=    get request  mysession  /rest/v2/alpha/IN
    #need to convert ${response} to JSON format
    ${json_obj}=    to json  ${response.content}

    #single data validation
    ${name_value}=  get value from json   ${json_obj}     $.name      #ham nay tra ve array, nen lay value tu index=0
    log to console  ${name_value[0]}
    should be equal  ${name_value[0]}   India

    #single data in array
    ${borders0_value}=    get value from json  ${json_obj}  $.borders[0]
    log to console  ${borders0_value[0]}
    should be equal  ${borders0_value[0]}   AFG

    #multiple data in array
    ${borders_value}=    get value from json  ${json_obj}  $.borders
    log to console  ${borders_value[0]}
    #should be equal  ${borders_value[0]}   AFG
    should contain any  ${borders_value[0]}     AFG     BGD     BTN     MMR     CHN     NPL1
    should not contain any  ${borders_value[0]}     AFG





