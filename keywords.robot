*** Keywords ***

Open Connection and Log In
    [Documentation]    Open SSH connection with ip passed as argument and log
    ...                in to system.
    [Arguments]    ${ip}    ${alias}
    SSH Connection and Log In    ${ip}    ${alias}
    ${result}=    Get Relay State
    Run Keyword If    '${result}'=='0'    RteCtrl Relay
    Sleep    1s
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
    keywords.REST API Setup    RteCtrl    ${rte_ip}

Serial Connection and Log In
    [Documentation]    Setup telnet connection and log in to system. Pass host
    ...                ip as an argument.
    [Arguments]    ${host}
    Telnet.Open Connection    ${host}    port=${s2n_port2}
    Telnet.Set Encoding    errors=ignore
    Telnet.Set Timeout    300
    Telnet.Set Prompt    \~#
    Telnet.Write    \n
    Telnet.Login    ${dut_user}    ${dut_pwd}

Prepare Test Suite
    [Documentation]    Opens all required connections on RTE and sets DUT to
    ...                unified start state.
    Open Connection and Log In    ${rte_ip}    RTE
    Telnet.Read
    ${old_runtime}=    Get RuntimeWatchdogSec

REST API Setup
    [Arguments]    ${session_handler}    ${ip}
    RequestsLibrary.Create Session    ${session_handler}    http://${ip}:${http_port}    verify=True

RteCtrlDUT Relay
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${relay}=    Get Request     RteCtrlDUT     /api/v1/gpio/0    ${headers}
    ${state}=    Evaluate    int((${relay.json()["state"]}+1)%2)
    ${message}=    Create Dictionary     state=${state}    direction=out    time=${0}
    ${relay}=    Patch Request    RteCtrlDUT    /api/v1/gpio/0    ${message}    headers=${headers}
    [Return]    ${state}

RteCtrlDUT Power On
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${1}
    ${power}=    Patch Request    RteCtrlDUT    /api/v1/gpio/9    ${message}    headers=${headers}

RteCtrlDUT Power Off
    ${headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${message}=    Create Dictionary     state=${1}    direction=out    time=${5}
    ${power}=    Patch Request    RteCtrlDUT    /api/v1/gpio/9    ${message}    headers=${headers}
    Sleep    5s

Hard Reboot DUT
    [Documentation]    Hard reboot Device Under Test.
    ${result}=    RteCtrl Relay
    Sleep    1 seconds
    Run Keyword If   ${result}==0  RteCtrl Relay

Soft Reboot DUT
    [Documentation]    Soft reboot Device Under Test.
    Telnet.Write Bare   reboot\n
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
    ...    ELSE IF    '${device}'=='DUT'    Telnet.Write    sleep 1 && echo -e "${msg}" > ${port} &
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
    [Documentation]    Parse available devices addresses from list passed as an
    ...                argument. Returns list with parsed results.
    [Arguments]    ${items}
    ${list}=    Create List
    :FOR    ${item}    IN    @{items}
    \    ${str}=    String.Get Substring    ${item}    3
    \    ${match}=    String.Get Regexp Matches    ${str}    [0-9a-fU][0-9a-fU]
    \    Run Keyword If    ${match}    Loop Through Match List    ${match}    ${list}
    [Return]    ${list}

Get Sign of Life
    [Documentation]    Return any sign of life after flashing firmware.
    Telnet.Open Connection    ${rte_ip}    port=${s2n_port1}
    Telnet.Set Encoding    errors=ignore
    Telnet.Set Timeout    120s
    RteCtrlDUT Power Off
    Sleep    1s
    # read the old output
    Telnet.Read
    RteCtrlDUT Power On
    ${sign_of_life}=    Telnet.Read Until    DRAM
    Telnet.Close Connection
    Telnet.Switch Connection    1
    [Return]    ${sign_of_life}

Flash apu2
    [Documentation]    Flashes apu2/3/4/5 platform with flashrom.
    RteCtrlDUT Power Off
    ${flash_result}=    Telnet.Execute Command    flashrom -f -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -w /tmp/coreboot.rom
    Return From Keyword If    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
    Should Contain    ${flash_result}     VERIFIED

Flash apu1
    [Documentation]    Flashes apu1 platform with flashrom.
    RteCtrlDUT Power Off
    ${flash_result}=    Telnet.Execute Command    flashrom -f -c MX25L1605A/MX25L1606E/MX25L1608E -p linux_spi:dev=/dev/spidev1.0,spispeed=16000 -w /tmp/coreboot.rom
    Return From Keyword If    "Warning: Chip content is identical to the requested image." in """${flash_result}"""
    Should Contain    ${flash_result}     VERIFIED

SPI Flash Firmware
    [Documentation]    Flash APUx firmware connected to DUT via SPI.
    [Arguments]    ${file}
    ${result}=    RteCtrlDUT Relay
    Sleep    1s
    Run Keyword If   ${result}==0  RteCtrlDUT Relay
    ${result}=    SSHLibrary.Put File    ${file}    destination=/tmp/coreboot.rom
    Run Keyword If    '${platform}' == 'apu1'    Flash apu1
    ...    ELSE IF    '${platform}' == 'apu2'    Flash apu2
    ...    ELSE IF    '${platform}' == 'apu3'    Flash apu2
    ...    ELSE IF    '${platform}' == 'apu4'    Flash apu2
    ...    ELSE IF    '${platform}' == 'apu5'    Flash apu2
    ...    ELSE    Log    ERROR    Unknown platform ${platform}

Get RuntimeWatchdogSec
    [Documentation]    Get RuntimeWatchdogSec value from /etc/systemd/system.conf.
    Telnet.Write Bare    cat /etc/systemd/system.conf | grep RuntimeWatchdog\n
    ${lines}=    Telnet.Read Until Prompt
    ${line}=    Get Lines Containing String    ${lines}    RuntimeWatchdogSec=
    ${value}=    String.Remove String    ${line}     RuntimeWatchdogSec=    \r\nroot@orange-pi-zero:~#
    ${out}=    Run Keyword If    '${value[0]}'=='#'    String.Get Substring    ${value}    1
    ...        ELSE    Set Variable    ${value}
    [Return]    ${out}

Set RuntimeWatchdogSec
    [Documentation]    Configure the hardware watchdog's timeout for tests.
    [Arguments]    ${old_value}    ${new_value}
    Return From Keyword If    '${old_value}'=='${new_value}'
    Telnet.Write Bare    sed -i '/RuntimeWatchdogSec=${old_value}/c\RuntimeWatchdogSec=${new_value}' /etc/systemd/system.conf\n
    Telnet.Read Until Prompt
    # reexecute daemon
    Telnet.Write Bare    systemctl daemon-reexec\n
    ${result}=    Telnet.Read Until Prompt
    ${tmp}=    Get RuntimeWatchdogSec
    Should Be Equal    ${tmp}    ${new_value}

Rollback RuntimeWatchdogSec
    [Documentation]    Rollback the changes on the hardware watchdog's timeout.
    Telnet.Write Bare    sed -i '/RuntimeWatchdogSec=${new_runtime}/c\RuntimeWatchdogSec=${old_runtime}' /etc/systemd/system.conf\n
    # reexecute daemon
    Telnet.Write Bare    systemctl daemon-reexec\n
    ${result}=    Telnet.Read Until Prompt
    ${tmp}=    Get RuntimeWatchdogSec
    Should Be Equal    ${tmp}    ${old_runtime}

Start fork-bomb
    [Documentation]   Start fork-bomb function on DUT platform.
    Telnet.Write Bare    bomb() { bomb | bomb & }; bomb\n

Crash kernel
    [Documentation]    Crash kernel on DUT via SysRq key.
    Telnet.Write Bare    sync; sleep 2; sync; echo c > /proc/sysrq-trigger\n

Cbfstool Get Contents
    [Documentation]    Returns printed contents of the ROM specified by an
    ...                argument.
    [Arguments]    ${file}
    SSHLibrary.Open Connection    ${dut_ip}    DUT
    SSHLibrary.Switch Connection    DUT
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    ${result}=    SSHLibrary.Put File    ${file}    destination=${fw_path}
    SSHLibrary.Close Connection
    SSHLibrary.Switch Connection    RTE
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
    SSHLibrary.Open Connection    ${dut_ip}    DUT
    SSHLibrary.Switch Connection    DUT
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    ${result}=    SSHLibrary.Put File    ${file}    destination=${fw_path}
    SSHLibrary.Close Connection
    SSHLibrary.Switch Connection    RTE
    Telnet.Write Bare    ifdtool -d ${fw_path}\n
    ${out}=    Telnet.Read Until Prompt
    [Return]    ${out}
