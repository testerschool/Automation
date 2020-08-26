*** Settings ***
Library     JSONLibrary
Library  os
Library  Collections

*** Test Cases ***
Testcase1:
    #load json from file
    ${json_obj}=    load json from file   Resources/jsondata.json
    ${name_value}=  get value from json     ${json_obj}     $.name
    log to console  ${name_value[0]}
    should be equal  ${name_value[0]}  John

    ${streetAddress_value}=  get value from json     ${json_obj}     $.address.streetAddress
    log to console  ${streetAddress_value[0]}
    should be equal  ${streetAddress_value[0]}  xyz

    ${faxNumber_value}=  get value from json     ${json_obj}     $.phoneNumber[1].number
    log to console  ${faxNumber_value[0]}
    should be equal  ${faxNumber_value[0]}  555121