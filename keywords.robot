*** Keywords ***

Open Connection and Log In
    [Documentation]    Open SSH connection with ip passed as argument and log
    ...                in to system.
    [Arguments]    ${ip}    ${alias}
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${ip}    alias=${alias}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    REST API Setup    RteCtrl

Log Out And Close Connection
    SSHLibrary.Close All Connections
    Telnet.Close All Connections

Serial Connection and Log In
    [Documentation]    Setup telnet connection and log in to system. Pass host
    ...                ip as an argument.
    [Arguments]    ${host}
    Telnet.Open Connection    ${host}    port=${s2n_port}
    Telnet.Set Encoding    errors=ignore
    Telnet.Set Timeout    60
    Telnet.Set Prompt    \~#
    Telnet.Write    \n
    Telnet.Login    ${dut_user}    ${dut_pwd}
    #Telnet.Read Until Prompt

Hard Reboot DUT
    [Documentation]    Hard reboot Device Under Test.
    ${result}=    RteCtrl Relay
    Sleep    1 seconds
    Run Keyword If   ${result}==0  RteCtrl Relay

Soft Reboot DUT
    [Documentation]    Soft reboot Device Under Test.
    Telnet.Write   reboot\n
    Telnet.Close Connection
