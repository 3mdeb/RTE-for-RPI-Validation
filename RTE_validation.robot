*** Settings ***
Library     SSHLibrary    timeout=30 seconds
Library     Telnet        timeout=30 seconds
Library     RequestsLibrary
Library     Collections
Library     String
Library     OperatingSystem

Resource    rtectrl-rest-api/rtectrl.robot
Resource    variables.robot
Resource    keywords.robot

Suite Setup       Open Connection and Log In    ${rte_ip}    RTE
Suite Teardown    Log Out And Close Connection

*** Test Cases ***
SSH 1.1 Test SSH after coldboot
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Hard Reboot DUT
    \    Telnet.Read Until    login:
    \    SSH Connection and Log In    ${dut_ip}    DUT
    \    ${ssh_info}=    SSHLibrary.Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${dut_ip}
    \    SSHLibrary.Close connection
    \    SSHLibrary.Switch Connection    RTE

SSH 1.2 Test SSH after warmboot
    [Teardown]    Run Keyword If Test Failed    Reboot and Reconnect
    : FOR    ${reboot}    IN RANGE    0    ${repeat}
    \    Soft Reboot DUT
    \    Telnet.Login    ${dut_user}    ${dut_pwd}
    \    SSH Connection and Log In    ${dut_ip}    DUT
    \    ${ssh_info}=    SSHLibrary.Get Connection
    \    Should Be Equal As Strings    ${ssh_info.host}    ${dut_ip}
    \    SSHLibrary.Close connection
    \    SSHLibrary.Switch Connection    RTE

USB 2.1 USB port 1 (J6) validation
    ${result}=    USB storage detection    /dev/sda
    Should Not Contain    ${result}    No such file or directory
    ${info}=    Get USB Device    ${usb1}

USB 2.2 USB port 2 (J8) validation
    ${result}=    USB storage detection    /dev/sdb
    Should Not Contain    ${result}    No such file or directory
    ${info}=    Get USB Device    ${usb2}

RS232 3.1 Loopback validation
    ${msg}=    Set Variable    Test RS232
    Telnet.Set Timeout    10 seconds
    Send Serial Msg    DUT    ${rs232}    ${msg}
    Start Listening On Serial Port    DUT    ${rs232}
    ${result}=    Telnet.Read Until    ${msg}

GPIO 4.1 Loopback validation RTE IN / DUT OUT
    GPIO Set All Directions    RTE    in
    GPIO Set All Directions    DUT    out
    :FOR    ${index}    IN RANGE    0    2
    \    GPIO Set All Values    DUT    1
    \    Sleep    1 seconds
    \    @{gpio_values}=    GPIO Get All Values    RTE
    \    Collections.List Should Not Contain Value    ${gpio_values}    0
    \    GPIO Set All Values    DUT    0
    \    Sleep    1 seconds
    \    @{gpio_values}=    GPIO Get All Values    RTE
    \    Collections.List Should Not Contain Value    ${gpio_values}    1
    \    ${index}=    Set Variable    ${index + 1}

GPIO 4.2 Loopback validation RTE OUT / DUT IN
    GPIO Set All Directions    DUT    in
    GPIO Set All Directions    RTE    out
    :FOR    ${index}    IN RANGE    0    2
    \    GPIO Set All Values    RTE    1
    \    Sleep    1 seconds
    \    @{gpio_values}=    GPIO Get All Values    DUT
    \    Collections.List Should Not Contain Value    ${gpio_values}    0
    \    GPIO Set All Values    RTE    0
    \    Sleep    1 seconds
    \    @{gpio_values}=    GPIO Get All Values    DUT
    \    Collections.List Should Not Contain Value    ${gpio_values}    1
    \    ${index}=    Set Variable    ${index + 1}

I2C 5.1 interface validation
    ${addresses}=    Set Variable
    ${busses}=    I2C Get Available Busses
    :FOR    ${bus}    IN    @{busses}
    \    ${result}=    I2C Get Device Addresses    ${bus}
    \    ${string}=    String. Get Lines Containing String    ${result}    -- --
    \    ${lines}=    String.Split To Lines    ${string}
    \    ${addresses}=    I2C Parse Device Addresses    ${lines}
    # BMA220 default address = 0a
    Run Keyword If    ${addresses}
    ...    Collections.List Should Contain Value    ${addresses}    0a
    ...    ELSE    Fail    No I2C devices detected

SPI 6.1 interface validation
    ${version}=    String.Get Substring    ${fw_file}    5    -4
    Rest API Setup    RteCtrlDUT    ${dut_ip}
    SPI Flash Firmware    ${fw_file}
    ${result}=    Get Sign of Life
    Should Contain    ${result}    ${version}
