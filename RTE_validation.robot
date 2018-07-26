*** Settings ***
Library     SSHLibrary    timeout=30 seconds
Library     Telnet        timeout=30 seconds
Library     RequestsLibrary

Resource    rtectrl-rest-api/rtectrl.robot
Resource    variables.robot
Resource    keywords.robot

Suite Setup       Open Connection and Log In    ${rte_ip}    RTE
Suite Teardown    Log Out And Close Connection

*** Test Cases ***
SSH 1.1 Test SSH after coldboot
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Hard Reboot DUT
    \    Sleep    ${sleep} seconds
    \    Open Connection and Log In    ${dut_ip}    DUT
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
    \    Open Connection and Log In    ${dut_ip}    DUT
    \    ${ssh_info}=    SSHLibrary.Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${dut_ip}
    \    SSHLibrary.Close connection
    \    SSHLibrary.Switch Connection    RTE
    \    ${reboot} =    Set Variable    ${reboot + 1}

USB 2.1 USB port 1 (J6) validation
    ${result}=    USB storage detection    /dev/sda
    Should Not Contain    ${result}    No such file or directory
    Log    Port 1 (J6):    Get USB Device    ${usb1}

USB 2.2 USB port 2 (J8) validation
    ${result}=    USB storage detection    /dev/sdb
    Should Not Contain    ${result}    No such file or directory
    Log    Port 2 (J8):    Get USB Device    ${usb2}
