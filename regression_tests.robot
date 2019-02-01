*** Settings ***
Library     SSHLibrary    timeout=30 seconds
Library     Telnet        timeout=30 seconds
Library     RequestsLibrary
Library     String
Library     OperatingSystem

Resource    rtectrl-rest-api/rtectrl.robot
Resource    variables.robot
Resource    keywords.robot

Suite Setup       Prepare Test Suite
Suite Teardown    Log Out And Close Connection

*** Test Cases ***

BOT1.1 Coldboot validation
    [Teardown]    Run Keyword If Test Failed    Wait Until Keyword Succeeds
    ...           5x    1s    Reboot and Reconnect
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Hard Reboot DUT
    \    ${out}=    Telnet.Read Until    login:
    \    Run Keyword And Continue On Failure    Should Not Contain Any    ${out}    @{error_list}

BOT1.2 Warmboot validation
    [Teardown]    Run Keyword If Test Failed    Wait Until Keyword Succeeds
    ...           5x    1s    Reboot and Reconnect
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Soft Reboot DUT
    \    ${out}=    Telnet.Login    ${dut_user}    ${dut_pwd}
    \    Run Keyword And Continue On Failure    Should Not Contain Any    ${out}    @{error_list}

WDT2.1 Watchdog manual reset
    [Teardown]    Run Keyword If Test Failed    Wait Until Keyword Succeeds
    ...           5x    1s    Reboot and Reconnect
    Telnet.Write Bare   ls /dev/watchdog\n
    ${out}=    Telnet.Read Until Prompt
    Should Not Contain    ${out}    No such file or directory
    Set RuntimeWatchdogSec    ${old_runtime}    0
    Telnet.Write Bare   echo 1 > /dev/watchdog\n
    Telnet.Set Timeout    60 seconds
    ${out}=    Telnet.Read Until Prompt
    Should Not Contain    ${out}    /dev/watchdog: Device or resource busy
    ${out}=    Telnet.Login    ${dut_user}    ${dut_pwd}
    Should Contain    ${out}    Starting kernel

WDT2.2 Watchdog sysrq trigger - fixed WDT
    [Teardown]    Run Keyword If Test Failed    Wait Until Keyword Succeeds
    ...           5x    1s    Reboot and Reconnect
    ${old_value}=    Get RuntimeWatchdogSec
    Set RuntimeWatchdogSec    ${old_value}    ${old_runtime}
    Crash kernel
    Telnet.Set Timeout    60 seconds
    # test if WDT performed reboot:
    ${out}=    Telnet.Login    ${dut_user}    ${dut_pwd}
    Should Contain    ${out}    Starting kernel

TOL3.1 CBFStool validation
    ${result}=    Cbfstool Get Contents    ${cbfs_file}
    Should Not Contain    ${result}    No such file or directory
    Should Not Contain    ${result}    Selected image region is not a valid CBFS.
    Log    ${result}

TOL3.2 IFDtool validation
    ${version}=    Ifdtool Get Version
    Log    ${version}
    ${descriptor}=    Ifdtool Dump Descriptor    ${ifd_file}
    Should Not Contain    ${descriptor}    No such file or directory
    Should Not Contain    ${descriptor}    No Flash Descriptor found in this image
    Log    ${descriptor}

SWU1.0 Rte sw-update
    ${mounted_from}=    Telnet.Execute Command    mount
    ${get_p_number}=    Get Line    ${mounted_from}    0
    ${p2}=    Evaluate    '${get_p_number[13]}'=='2'
    ${p3}=    Evaluate    '${get_p_number[13]}'=='3'
    ${p_number}=    Set Variable If
    ...    ${p2}    2
    ...    ${p3}    3
    SSHLibrary.Open Connection    ${dut_ip}    DUT
    SSHLibrary.Switch Connection    DUT
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    SSHLibrary.Put File    ${sw_image}    root@${rte_ip}:/tmp/image.swu
    SSHLibrary.Close Connection
    SSHLibrary.Execute Command    rte-upgrade upgrade /tmp/image.swu
    SSHLibrary.Write    journalctl -fu confirm-upgrade
    : FOR    ${INDEX}    IN RANGE    0    3
    \    ${mounted_from}=    Telnet.Execute Command    mount
    \    ${get_p_number}=    Get Line    ${mounted_from}    0
    \    Run keyword if    '${p_number}'=='2'
    \    ...    Should Be Equal    ${get_p_number[13]}    3
    \    ...    ELSE    Should Be Equal    ${get_p_number[13]}    2
    \    Telnet.Write    reboot
