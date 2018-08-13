*** Keywords ***
RteCtrl Relay
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     RteCtrl     /api/v1/gpio/0    ${headers}
    ${state}=    Evaluate    int((${relay.json()["state"]}+1)%2)
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${relay}=    Patch Request    RteCtrl    /api/v1/gpio/0    ${message}    headers=${headers}
    [Return]    ${state}

RteCtrl Power On
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${1}
    ${power}=    Patch Request    RteCtrl    /api/v1/gpio/9    ${message}    headers=${headers}

RteCtrl Power Off
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${5}
    ${power}=    Patch Request    RteCtrl    /api/v1/gpio/9    ${message}    headers=${headers}
    Sleep    5s

RteCtrl Reset
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${1}
    ${reset}=    Patch Request    RteCtrl    /api/v1/gpio/8    ${message}    headers=${headers}

RteCtrl Set OC GPIO
    [Arguments]    ${gpio_no}    ${gpio_state}
    Run Keyword If    int(${gpio_no}) > ${12}    Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${state}=    Set Variable If
    ...    '${gpio_state}' == 'high-z'    ${0}
    ...    '${gpio_state}' == 'low'    ${1}
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${response}=    Patch Request    RteCtrl    /api/v1/gpio/${gpio_no}    ${message}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

RteCtrl Set GPIO
    [Arguments]    ${gpio_no}    ${gpio_state}
    Run Keyword If    int(${gpio_no}) < ${13}    Fail    Wrong GPIO number
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${state}=    Set Variable If
    ...    '${gpio_state}' == 'high'    ${1}
    ...    '${gpio_state}' == 'low'    ${0}
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${response}=    Patch Request    RteCtrl    /api/v1/gpio/${gpio_no}    ${message}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

REST API Setup
    [Arguments]    ${session_handler}    ${ip}
    RequestsLibrary.Create Session    ${session_handler}    http://${ip}:${http_port}    verify=True

RteCtrlDUT Relay
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     RteCtrlDUT     /api/v1/gpio/0    ${headers}
    ${state}=    Evaluate    int((${relay.json()["state"]}+1)%2)
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${relay}=    Patch Request    RteCtrlDUT    /api/v1/gpio/0    ${message}    headers=${headers}
    [Return]    ${state}

RteCtrlDUT Power On
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${1}
    ${power}=    Patch Request    RteCtrlDUT    /api/v1/gpio/9    ${message}    headers=${headers}

RteCtrlDUT Power Off
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${5}
    ${power}=    Patch Request    RteCtrlDUT    /api/v1/gpio/9    ${message}    headers=${headers}
    Sleep    5s
