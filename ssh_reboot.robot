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
1. Test SSH after coldboot
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Hard Reboot DUT
    \    Sleep    ${sleep} seconds
    \    Open Connection and Log In    ${dut_ip}    DUT
    \    ${ssh_info}=    SSHLibrary.Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${dut_ip}
    \    SSHLibrary.Close connection
    \    SSHLibrary.Switch Connection    RTE
    \    ${reboot} =    Set Variable    ${reboot + 1}

2. Test SSH after warmboot
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
