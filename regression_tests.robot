*** Settings ***
Library     SSHLibrary    timeout=30 seconds
Library     Telnet        timeout=30 seconds
Library     RequestsLibrary
Library     String
Library     OperatingSystem

Resource    rtectrl-rest-api/rtectrl.robot
Resource    variables.robot
Resource    keywords.robot

Suite Setup       Open Connection and Log In    ${rte_ip}    RTE
Suite Teardown    Run Keywords    Rollback RuntimeWatchdogSec
                  ...             Log Out And Close Connection

*** Test Cases ***
1.1 Coldboot validation
    [Teardown]    Run Keyword If Timeout Occurred    Reboot and Reconnect
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Hard Reboot DUT
    \    ${out}=    Telnet.Read Until    login:
    \    Run Keyword And Continue On Failure    Should Not Contain Any    ${out}    @{error_list}

1.2 Warmboot validation
    [Teardown]    Run Keyword If Timeout Occurred    Reboot and Reconnect
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Soft Reboot DUT
    \    ${out}=    Telnet.Login    ${dut_user}    ${dut_pwd}
    \    Run Keyword And Continue On Failure    Should Not Contain Any    ${out}    @{error_list}

2.1 Watchdog manual reset
    [Teardown]    Run Keyword If Timeout Occurred    Reboot and Reconnect
    ${out}=    Telnet.Execute Command    ls /dev/watchdog
    Should Not Contain    ${out}    No such file or directory
    Telnet.Write    echo 1 > /dev/watchdog
    ${out}=    Telnet.Read Until   watchdog did not stop!
    ${out}=    Telnet.Login    ${dut_user}    ${dut_pwd}
    Should Contain    ${out}    Starting kernel

2.2 Watchdog fork-bomb - fixed WDT
    [Teardown]    Run Keyword If Timeout Occurred    Reboot and Reconnect
    ${old_runtime}=    Get RuntimeWatchdogSec
    # start fork-bomb
    Telnet.Write    bomb() { bomb | bomb & }; bomb
    # test if WDT performed reboot:
    ${out}=    Telnet.Login    ${dut_user}    ${dut_pwd}
    Should Contain    ${out}    Starting kernel

2.3 Watchdog fork-bomb - custom WDT
    [Teardown]    Run Keyword If Timeout Occurred    Reboot and Reconnect
    Run Keyword If    '${old_runtime}'!='${new_runtime}'    Set RuntimeWatchdogSec
    # reexecute daemon
    Telnet.Write    systemctl daemon-reexec
    Telnet.Read Until Prompt
    # start fork-bomb
    Telnet.Write    bomb() { bomb | bomb & }; bomb
    # test if WDT performed reboot:
    ${out}=    Telnet.Login    ${dut_user}    ${dut_pwd}
    Should Contain    ${out}    Starting kernel

3.1 CBFStool validation
    ${result}=    Cbfstool Get Contents    ${cbfs_file}
    Should Not Contain    ${result}    Selected image region is not a valid CBFS.
    Log    ${result}

3.2 IFDtool validation
    ${version}=    Ifdtool Get Version
    Log    ${version}
    ${descriptor}=    Ifdtool Dump Descriptor    ${ifd_file}
    Should Not Contain    ${descriptor}    No Flash Descriptor found in this image
    Log    ${descriptor}
