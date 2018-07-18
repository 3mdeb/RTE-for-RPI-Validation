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

Serial Setup
    [Documentation]    Setup telnet connection. Pass host address where serial
    ...                is redirected as arguments.
    [Arguments]    ${host}
    Telnet.Open Connection    ${host}    port=${s2n_port}
    # remove encoding setup for terminal emulator pyte
    Telnet.Set Encoding    errors=ignore
    Set Timeout    15

Serial Login DUT
    [Documentation]    Login to system via serial. Pass username and password as
    ...                an argument.
    [Arguments]    ${username}    ${password}
    Telnet.Set Timeout    30
    Telnet.Set Prompt    \~#
    Telnet.Login    ${username}    ${password}
    Telnet.Read Until Prompt

Hard Reboot DUT
    [Documentation]    Hard reboot Device Under Test.
    ${result}=    RteCtrl Relay
    sleep    1 seconds
    Run Keyword If   ${result}==0  RteCtrl Relay

Soft Reboot DUT
    [Documentation]    Soft reboot Device Under Test.
    Telnet.Execute Command    reboot\n
