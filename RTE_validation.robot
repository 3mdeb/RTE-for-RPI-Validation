*** Settings ***
Library     SSHLibrary    timeout=30 seconds
Library     Telnet        timeout=30 seconds
Library     RequestsLibrary
Library     Collections
Library     String

Resource    rtectrl-rest-api/rtectrl.robot
Resource    variables.robot
Resource    keywords.robot

Suite Setup       Open Connection and Log In    ${rte_ip}    RTE
Suite Teardown    Log Out And Close Connection

*** Test Cases ***
SSH 1.1 Test SSH after coldboot
    Telnet.Close Connection
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Hard Reboot DUT
    \    Sleep    ${sleep} seconds
    \    SSH Connection and Log In    ${dut_ip}    DUT
    \    ${ssh_info}=    SSHLibrary.Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${dut_ip}
    \    SSHLibrary.Close connection
    \    SSHLibrary.Switch Connection    RTE
    \    ${reboot} =    Set Variable    ${reboot + 1}

SSH 1.2 Test SSH after warmboot
    Serial Connection and Log In    ${rte_ip}
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Soft Reboot DUT
    \    Serial Connection and Log In    ${rte_ip}
    \    SSH Connection and Log In    ${dut_ip}    DUT
    \    ${ssh_info}=    SSHLibrary.Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${dut_ip}
    \    SSHLibrary.Close connection
    \    SSHLibrary.Switch Connection    RTE
    \    ${reboot}=    Set Variable    ${reboot + 1}

USB 2.1 USB port 1 (J6) validation
    ${result}=    USB storage detection    /dev/sda
    Should Not Contain    ${result}    No such file or directory
    ${info}=    Get USB Device    ${usb1}

USB 2.2 USB port 2 (J8) validation
    ${result}=    USB storage detection    /dev/sdb
    Should Not Contain    ${result}    No such file or directory
    ${info}=    Get USB Device    ${usb2}

RS232 3.1 communication to DUT validation
    ${msg}=    Set Variable    Test #1 RS232
    Start Listening On Serial Port    DUT    ${rs232}
    Send Serial Msg    RTE    ${rs232}    ${msg}
    ${result}=    Telnet.Read Until    ${msg}

RS232 3.2 communication from DUT validation
    ${msg}=    Set Variable    Test #2 RS232
    Start Listening On Serial Port    RTE    ${rs232}
    Send Serial Msg    DUT    ${rs232}    ${msg}
    ${result}=    SSHLibrary.Read Until    ${msg}

GPIO 4.1 Loopback validation RTE IN / DUT OUT
    GPIO Set All Directions    RTE    in
    GPIO Set All Directions    DUT    out
    :FOR    ${index}    IN RANGE    0    2
    \    GPIO Set All Values    DUT    1
    \    Sleep    1 seconds
    \    @{gpio_values}=    GPIO Get All Values    RTE
    \    Collections.List Should Not Contain Value    ${gpio_values}    0
    \    GPIO Set All Values    DUT    0
    \    Sleep    1 seconds
    \    @{gpio_values}=    GPIO Get All Values    RTE
    \    Collections.List Should Not Contain Value    ${gpio_values}    1
    \    ${index}=    Set Variable    ${index + 1}

GPIO 4.2 Loopback validation RTE OUT / DUT IN
    GPIO Set All Directions    DUT    in
    GPIO Set All Directions    RTE    out
    :FOR    ${index}    IN RANGE    0    1
    \    GPIO Set All Values    RTE    1
    \    Sleep    1 seconds
    \    @{gpio_values}=    GPIO Get All Values    DUT
    \    Collections.List Should Not Contain Value    ${gpio_values}    0
    \    GPIO Set All Values    RTE    0
    \    Sleep    1 seconds
    \    @{gpio_values}=    GPIO Get All Values    DUT
    \    Collections.List Should Not Contain Value    ${gpio_values}    1
    \    ${index}=    Set Variable    ${index + 1}
