*** Settings ***
Library     SSHLibrary    timeout=30 seconds

Resource    variables.robot
Resource    keywords.robot

Test Setup       Open Connection and Log In    ${rte_ip}
Test Teardown    SSHLibrary.Close All Connections

*** Test Cases ***

1. Test SSH after reboot
    Enable SSH Logging    ${log_file}
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Reboot RTE
    \    SSHLibrary.Close Connection
    \    Sleep    ${sleep} seconds
    \    Open Connection and Log In    ${rte_ip}
    \    ${ssh_info}=    Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${rte_ip}
    \    ${reboot} =    Set Variable    ${reboot + 1}
