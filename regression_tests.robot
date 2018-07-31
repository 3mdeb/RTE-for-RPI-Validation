*** Settings ***
Library     SSHLibrary    timeout=30 seconds
Library     Telnet        timeout=30 seconds
Library     RequestsLibrary
Library     String

Resource    rtectrl-rest-api/rtectrl.robot
Resource    variables.robot
Resource    keywords.robot

Suite Setup       Open Connection and Log In    ${rte_ip}    RTE
Suite Teardown    Run Keywords    Rollback RuntimeWatchdogSec
                  ...             Log Out And Close Connection

*** Test Cases ***
1.1 Coldboot validation
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Hard Reboot DUT
    \    ${out}=    Telnet.Read Until    login:
    \    Run Keyword And Continue On Failure    Should Not Contain Any    ${out}    @{error_list}

1.2 Warmboot validation
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Soft Reboot DUT
    \    ${out}=    Telnet.Login    ${dut_user}    ${dut_pwd}
    \    Run Keyword And Continue On Failure    Should Not Contain Any    ${out}    @{error_list}

2.1 Watchdog manual reset
    ${out}=    Telnet.Execute Command    ls /dev/watchdog
    Should Not Contain    ${out}    No such file or directory
    Telnet.Write    echo 1 > /dev/watchdog
    ${out}=    Telnet.Read Until   watchdog did not stop!
    Telnet.Login    ${dut_user}    ${dut_pwd}

2.2 Watchdog fork-bomb
    ${old_runtime}=    Get RuntimeWatchdogSec
    Run Keyword If    '${old_runtime}'!='${new_runtime}'    Set RuntimeWatchdogSec
    # execute fork-bomb
    #Telnet.Write    bomb() { bomb | bomb & }; bomb
    # test if WDT performed reboot:
    #Telnet.Login    ${dut_user}    ${dut_pwd}

3.1 cbfstool dump ROM content
    ${result}=    Cbfstool Get Contents    ${fw_file}
    Log    ${result}

3.2 ifdtool validation
    ${version}=    Ifdtool Get Version
    Log    ${version}
    ### dump intel firmware descriptor
    ### fw_file should be e.g. Libretrend's ROM
    ${descriptor}=    Ifdtool Dump Descriptor    ${fw_file}
    Log    ${descriptor}
