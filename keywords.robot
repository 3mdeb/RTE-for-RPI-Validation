*** Keywords ***

Open Connection and Log In
    [Documentation]    Open SSH connection with ip passed as argument and log
    ...                in to system.
    [Arguments]    ${ip}    ${alias}
    SSH Connection and Log In    ${ip}    ${alias}
    ${state}=    SSHLibrary.Execute Command    cat /sys/class/gpio/gpio199/value
    Run Keyword If   '${state}'=='0'    RteCtrl Relay
    Serial Connection and Log In    ${ip}

Log Out And Close Connection
    Telnet.Write    logout
    Telnet.Close All Connections
    SSHLibrary.Close All Connections

SSH Connection and Log In
    [Documentation]    Open SSH connection with ip passed as argument and log
    ...                in to system.
    [Arguments]    ${ip}    ${alias}
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${ip}    alias=${alias}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    REST API Setup    RteCtrl

Serial Connection and Log In
    [Documentation]    Setup telnet connection and log in to system. Pass host
    ...                ip as an argument.
    [Arguments]    ${host}
    Telnet.Open Connection    ${host}    port=${s2n_port}
    Telnet.Set Encoding    errors=ignore
    Telnet.Set Timeout    180
    Telnet.Set Prompt    \~#
    Telnet.Write    \n
    Telnet.Login    ${dut_user}    ${dut_pwd}

Hard Reboot DUT
    [Documentation]    Hard reboot Device Under Test.
    ${result}=    RteCtrl Relay
    Sleep    1 seconds
    Run Keyword If   ${result}==0  RteCtrl Relay

Soft Reboot DUT
    [Documentation]    Soft reboot Device Under Test.
    Telnet.Write   reboot\n
    #Telnet.Close Connection

Reboot and Reconnect
    [Documentation]    Restarts DUT and set Telnet connection for next test.
    ...                Use this keyword in test teardown.
    Hard Reboot DUT
    Telnet.Login    ${dut_user}    ${dut_pwd}

USB Storage Detection
    [Documentation]    Check USB storage correct detection. Pass device name as
    ...                an argument. Returns result as an output.
    [Arguments]    ${sdx}
    Telnet.Write Bare   ls ${sdx}\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}

Get USB Device
    [Documentation]    Returns information about USB device on specific port.
    [Arguments]    ${bus_num}
    Telnet.Write Bare    lsusb | grep -v 'Device 001' | grep '${bus_num}'\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}

Start Listening On Serial Port
    [Documentation]    Start listening on specified port.
    ...                Pass device and device's port as an argument.
    [Arguments]    ${device}    ${port}
    Should Contain Any    ${device}    RTE    DUT
    Run Keyword If    '${device}'=='RTE'    SSHLibrary.Write    head -n 1 < ${port}
    ...    ELSE IF    '${device}'=='DUT'    Telnet.Write    head -n 1 < ${port}
    ...    ELSE    Fail    'device' argument should contain RTE or DUT

Send Serial Msg
    [Documentation]    Send serial iface message via specified port. Pass
    ...                device, device's port and text to send as an arguments.
    [Arguments]    ${device}    ${port}    ${msg}
    Should Contain Any    ${device}    RTE    DUT
    Run Keyword If    '${device}'=='RTE'    SSHLibrary.Write    sleep 1 && echo -e "${msg}" > ${port}
    ...    ELSE IF    '${device}'=='DUT'    Telnet.Write    sleep 1 && echo -e "${msg}" > ${port}
    ...    ELSE    Fail    'device' argument should contain RTE or DUT

GPIO Set Direction
    [Documentation]    Sets device's GPIO direction. Pass device, gpio number
    ...                 and direction as an argument.
    [Arguments]    ${device}    ${gpio}    ${direction}
    Should Contain Any    ${device}    RTE    DUT
    Run Keyword If    '${device}'=='RTE'
    ...    SSHLibrary.Write    echo ${direction} > /sys/class/gpio/${gpio}/direction
    ...    ELSE IF    '${device}'=='DUT'
    ...    Telnet.Write    echo ${direction} > /sys/class/gpio/${gpio}/direction
    ...    ELSE    Fail    'device' argument should contain RTE or DUT

GPIO Set All Directions
    [Documentation]    Set directions for all tested GPIOs. Pass device for
    ...                configuration and GPIOs direction as an argument.
    [Arguments]    ${device}    ${direction}
    :FOR    ${gpio}    IN    @{gpio_list}
    \    GPIO Set Direction    ${device}    ${gpio}    ${direction}

GPIO Set Value
    [Documentation]    Sets device's GPIO value. Pass device, gpio number
    ...                 and value as an argument.
    [Arguments]    ${device}    ${gpio}    ${value}
    Should Contain Any    ${device}    RTE    DUT
    Run Keyword If    '${device}'=='RTE'
    ...    SSHLibrary.Write    echo ${value} > /sys/class/gpio/${gpio}/value
    ...    ELSE IF    '${device}'=='DUT'
    ...    Telnet.Write    echo ${value} > /sys/class/gpio/${gpio}/value
    ...    ELSE    Fail    'device' argument should contain RTE or DUT

GPIO Set All Values
    [Documentation]    Set values for all tested GPIOs. Pass device for
    ...                configuration and GPIOs value as an argument.
    [Arguments]    ${device}    ${value}
    :FOR    ${gpio}    IN    @{gpio_list}
    \    GPIO Set Value    ${device}    ${gpio}    ${value}

GPIO Telnet Read
    [Documentation]    Keyword for GPIO Get Value (due to the complexity).
    [Arguments]    ${gpio}
    Telnet.Write Bare    cat /sys/class/gpio/${gpio}/value\n
    ${out}=    Telnet.Read Until Regexp    \n[0-1]
    ${val}=    String.Get Substring    ${out}    -1
    [Return]    ${val}

GPIO Get Value
    [Documentation]    Keyword returns GPIO value. Pass device and gpio as an
    ...                argument.
    [Arguments]    ${device}    ${gpio}
    Should Contain Any    ${device}    RTE    DUT
    ${out}=    Run Keyword If    '${device}'=='RTE'
    ...    SSHLibrary.Execute Command    cat /sys/class/gpio/${gpio}/value
    ...    ELSE IF    '${device}'=='DUT'    GPIO Telnet Read    ${gpio}
    ...    ELSE    Fail    'device' argument should contain RTE or DUT
    [Return]    ${out}

GPIO Get All Values
    [Documentation]    Read values from all tested GPIOs and return list of
    ...                values. Pass device as an argument.
    [Arguments]    ${device}
    ${value_list}=    Create List
    :FOR    ${gpio}    IN    @{gpio_list}
    \    ${value}=    GPIO Get Value    ${device}    ${gpio}
    \    Collections.Append To List    ${value_list}    ${value}
    [Return]    @{value_list}

I2C Get Available Busses
    [Documentation]    Returns list of available I2C busses.
    Telnet.Write Bare    i2cdetect -l\n
    ${out}=    Telnet.Read Until Prompt
    ${list}=    String.Get Regexp Matches    ${out}    i2c-[0-9a-f]
    [Return]    ${list}

I2C Get Device Addresses
    [Documentation]    Returns addresses of available I2C devices on bus
    ...                specified in argument.
    [Arguments]    ${bus}
    ${bus_num}=    String.Get Substring    ${bus}    -1
    Telnet.Write Bare    i2cdetect -y ${bus_num}\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}

Loop Through Match List
    [Documentation]    Split string in list and append to main list.
    [Arguments]    ${tmp_list}    ${list}
    :FOR    ${tmp_item}    IN    @{tmp_list}
    \    Collections.Append To List    ${list}    ${tmp_item}
    [Return]    ${list}

I2C Parse Device Addresses
    [Arguments]    ${items}
    ${list}=    Create List
    :FOR    ${item}    IN    @{items}
    \    ${str}=    String.Get Substring    ${item}    3
    \    ${match}=    String.Get Regexp Matches    ${str}    [0-9a-fU][0-9a-fU]
    \    Run Keyword If    ${match}    Loop Through Match List    ${match}    ${list}
    [Return]    ${list}

Get RuntimeWatchdogSec
    [Documentation]    Get RuntimeWatchdogSec value from /etc/systemd/system.conf.
    ${tmp}=    Telnet.Execute Command    cat /etc/systemd/system.conf | grep RuntimeWatchdog
    ${tmp}=    String.Remove String    ${tmp}     RuntimeWatchdogSec=    \r\nroot@orange-pi-zero:~#
    ${out}=    Run Keyword If    '${tmp[0]}'=='#'    String.Get Substring    ${tmp}    1
    ...        ELSE    Set Variable    ${tmp}
    [Return]    ${out}

Set RuntimeWatchdogSec
    [Documentation]    Configure the hardware watchdog's timeout for tests.
    Telnet.Write    sed -i '/RuntimeWatchdogSec=${old_runtime}/c\RuntimeWatchdogSec=${new_runtime}' /etc/systemd/system.conf

Rollback RuntimeWatchdogSec
    [Documentation]    Rollback the changes on the hardware watchdog's timeout.
    Telnet.Write    sed -i '/RuntimeWatchdogSec=${new_runtime}/c\RuntimeWatchdogSec=${old_runtime}' /etc/systemd/system.conf

Start fork-bomb
    [Documentation]   Start fork-bomb function on DUT platform.
    Telnet.Write    bomb() { bomb | bomb & }; bomb

Cbfstool Get Contents
    [Documentation]    Returns printed contents of the ROM specified by an
    ...                argument.
    [Arguments]    ${file}
    #TODO: SSHLibrary.Put File    ${file}    ${fw_path}
    ${result}=    Run    sshpass -p ${dut_pwd} scp ${file} ${dut_user}@${dut_ip}:${fw_path}
    Should Be Empty    ${result}
    Telnet.Write Bare    cbfstool ${fw_path} print\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}

Ifdtool Get Version
    [Documentation]    Returns Ifdtool's version.
    Telnet.Write Bare    ifdtool --version\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}

Ifdtool Dump Descriptor
    [Documentation]    Returns dumped Intel firmware descriptor. Pass rom file
    ...                path as an argument.
    [Arguments]    ${file}
    #TODO: SSHLibrary.Put File    ${file}    ${fw_path}
    ${result}=    Run    sshpass -p ${dut_pwd} scp ${file} ${dut_user}@${dut_ip}:${fw_path}
    Should Be Empty    ${result}
    Telnet.Write Bare    ifdtool -d ${fw_path}\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}
