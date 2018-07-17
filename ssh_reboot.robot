*** Settings ***
Library     SSHLibrary    timeout=30 seconds
Library     Telnet        timeout=30 seconds

Resource    variables.robot
Resource    keywords.robot

Suite Setup       Open Connection and Log In    ${rte_ip}    RTE
Suite Teardown    Log Out And Close Connection

*** Test Cases ***

1. Test SSH after coldboot
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Coldboot DUT
    \    Sleep    ${sleep} seconds
    \    Open Connection and Log In    ${dut_ip}    DUT
    \    ${ssh_info}=    SSHLibrary.Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${dut_ip}
    \    SSHLibrary.Close connection
    \    SSHLibrary.Switch Connection    RTE
    \    ${reboot} =    Set Variable    ${reboot + 1}

2. Test SSH after warmboot
    Serial setup    ${dut_ip}
    Serial Login DUT    ${dut_user}    ${dut_pwd}
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Warmboot DUT
    \    #Sleep    ${sleep} seconds
    \    Serial setup    ${dut_ip}
    \    Serial Login DUT    ${dut_user}    ${dut_pwd}
    \    Open Connection and Log In    ${dut_ip}
    \    ${ssh_info}=    SSHLibrary.Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${dut_ip}
    \    SSHLibrary.Close connection
    \    ${reboot} =    Set Variable    ${reboot + 1}
