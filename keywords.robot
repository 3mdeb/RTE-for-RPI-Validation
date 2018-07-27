*** Keywords ***

Open Connection and Log In
    [Documentation]    Open SSH connection with ip passed as argument and log
    ...                in to system.
    [Arguments]    ${ip}    ${alias}
    SSH Connection and Log In    ${ip}    ${alias}
    Serial Connection and Log In    ${ip}

Log Out And Close Connection
    Telnet.Write    logout
    Telnet.Close All Connections
    SSHLibrary.Close All Connections

SSH Connection and Log In
    [Documentation]    Open SSH connection with ip passed as argument and log
    ...                in to system.
    [Arguments]    ${ip}    ${alias}
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${ip}    alias=${alias}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    REST API Setup    RteCtrl

Serial Connection and Log In
    [Documentation]    Setup telnet connection and log in to system. Pass host
    ...                ip as an argument.
    [Arguments]    ${host}
    Telnet.Open Connection    ${host}    port=${s2n_port}
    Telnet.Set Encoding    errors=ignore
    Telnet.Set Timeout    120
    Telnet.Set Prompt    \~#
    Telnet.Write    \n
    Telnet.Login    ${dut_user}    ${dut_pwd}

Hard Reboot DUT
    [Documentation]    Hard reboot Device Under Test.
    ${result}=    RteCtrl Relay
    Sleep    1 seconds
    Run Keyword If   ${result}==0  RteCtrl Relay

Soft Reboot DUT
    [Documentation]    Soft reboot Device Under Test.
    Telnet.Write   reboot\n
    Telnet.Close Connection

USB Storage Detection
    [Documentation]    Check USB storage correct detection. Pass device name as
    ...                an argument. Returns result as an output.
    [Arguments]    ${sdx}
    Telnet.Write Bare   ls ${sdx}\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}

Get USB Device
    [Documentation]    Returns information about USB device on specific port.
    [Arguments]    ${bus_num}
    Telnet.Write Bare    lsusb | grep -v 'Device 001' | grep '${bus_num}'\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}

Start Listening On Serial Port
    [Documentation]    Start listening on specified port.
    ...                Pass device and device's port as an argument.
    [Arguments]    ${device}    ${port}
    Should Contain Any    ${device}    RTE    DUT
    Run Keyword If    '${device}'=='RTE'    SSHLibrary.Write    head -n 1 < ${port}
    ...    ELSE IF    '${device}'=='DUT'    Telnet.Write    head -n 1 < ${port}
    ...    ELSE    Fail    'device' argument should contain RTE or DUT

Send Serial Msg
    [Documentation]    Send serial iface message via specified port. Pass
    ...                device, device's port and text to send as an arguments.
    [Arguments]    ${device}    ${port}    ${msg}
    Should Contain Any    ${device}    RTE    DUT
    Run Keyword If    '${device}'=='RTE'    SSHLibrary.Write    sleep 1 && echo -e "${msg}" > ${port}
    ...    ELSE IF    '${device}'=='DUT'    Telnet.Write    sleep 1 && echo -e "${msg}" > ${port}
    ...    ELSE    Fail    'device' argument should contain RTE or DUT

GPIO Set Direction
    [Documentation]    Sets device's GPIO direction. Pass device, gpio number
    ...                 and direction as an argument.
    [Arguments]    ${device}    ${gpio}    ${direction}
    Should Contain Any    ${device}    RTE    DUT
    Run Keyword If    '${device}'=='RTE'
    ...    SSHLibrary.Write    echo ${direction} > /sys/class/gpio/${gpio}/direction
    ...    ELSE IF    '${device}'=='DUT'
    ...    Telnet.Write    echo ${direction} > /sys/class/gpio/${gpio}/direction
    ...    ELSE    Fail    'device' argument should contain RTE or DUT

GPIO Set All Directions
    [Documentation]    Set directions for all tested GPIOs. Pass device for
    ...                configuration and GPIOs direction as an argument.
    [Arguments]    ${device}    ${direction}
    :FOR    ${gpio}    IN    @{gpio_list}
    \    GPIO Set Direction    ${device}    ${gpio}    ${direction}

GPIO Set Value
    [Documentation]    Sets device's GPIO value. Pass device, gpio number
    ...                 and value as an argument.
    [Arguments]    ${device}    ${gpio}    ${value}
    Should Contain Any    ${device}    RTE    DUT
    Run Keyword If    '${device}'=='RTE'
    ...    SSHLibrary.Write    echo ${value} > /sys/class/gpio/${gpio}/value
    ...    ELSE IF    '${device}'=='DUT'
    ...    Telnet.Write    echo ${value} > /sys/class/gpio/${gpio}/value
    ...    ELSE    Fail    'device' argument should contain RTE or DUT

GPIO Set All Values
    [Documentation]    Set values for all tested GPIOs. Pass device for
    ...                configuration and GPIOs value as an argument.
    [Arguments]    ${device}    ${value}
    :FOR    ${gpio}    IN    @{gpio_list}
    \    GPIO Set Value    ${device}    ${gpio}    ${value}

GPIO Get Value
    [Documentation]    Keyword returns GPIO value. Pass device and gpio as an
    ...                argument.
    [Arguments]    ${device}    ${gpio}
    Should Contain Any    ${device}    RTE    DUT
    ${out}=    Run Keyword If    '${device}'=='RTE'
    ...    SSHLibrary.Execute Command    cat /sys/class/gpio/${gpio}/value
    ...    ELSE IF    '${device}'=='DUT'
    ...    Telnet.Write    cat /sys/class/gpio/${gpio}/value
    ...    Telnet.Read Until Regex    [0-1]
    ...    ELSE    Fail    'device' argument should contain RTE or DUT
    [Return]    ${out}

GPIO Get All Values
    [Documentation]    Read values from all tested GPIOs and return list of
    ...                values. Pass device as an argument.
    [Arguments]    ${device}
    ${value_list}=    Create List
    :FOR    ${gpio}    IN    @{gpio_list}
    \    ${value}=    GPIO Get Value    ${device}    ${gpio}
    \    Collections.Append To List    ${value_list}    ${value}
    [Return]    @{value_list}
