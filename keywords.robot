*** Keywords ***

Check if GPIO is exported
    [Documentation]  Takes GPIO number as an argument. Returns true
    ...              if it is exportet in sysfs. Returns false otherwise.
    [Arguments]  ${gpio_number}
    ${gpio_path} =  Catenate  SEPARATOR=  /sys/class/gpio/gpio  ${gpio_number}
    ${cmd} =  Catenate  ls  ${gpio_path}
    ${rc} =  SSHLibrary.Execute Command  ${cmd}  return_stdout=False  return_rc=True
    [Return]  ${rc}

Export GPIO
    [Documentation]  Takes GPIO number as an argument. Exports it in sysfs.
    [Arguments]  ${gpio_number}
    # export GPIO
    ${cmd} =  Catenate  echo  ${gpio_number}  > /sys/class/gpio/export
    SSHLibrary.Execute Command  ${cmd}
    # set as output
    ${cmd} =  Catenate  echo  out > /sys/class/gpio/gpio
    ${cmd} =  Catenate  SEPARATOR=  ${cmd}  ${gpio_number}  /direction
    SSHLibrary.Execute Command  ${cmd}

Unexport GPIO
    [Documentation]  Takes GPIO number as an argument. Unexports it from sysfs.
    [Arguments]  ${gpio_number}
    ${cmd} =  Catenate  echo  ${gpio_number}  > /sys/class/gpio/unexport
    SSHLibrary.Execute Command  ${cmd}

Set GPIO value
    [Documentation]  Takes GPIO number as an argument. Sets it to output with given value.
    [Arguments]  ${gpio_number}  ${value}
    ${exported} =  Check if GPIO is exported  ${gpio_number}
    Run Keyword If  ${exported} != 0  Export GPIO  ${gpio_number}
    ${cmd} =  Catenate  echo  ${value}  > /sys/class/gpio/gpio
    ${cmd} =  Catenate  SEPARATOR=  ${cmd}  ${gpio_number}  /value
    SSHLibrary.Execute Command  ${cmd}

Drive GPIO high
    [Documentation]  Takes GPIO number as an argument. Sets it to output and drives high.
    [Arguments]    ${gpio_number}
    Set GPIO value    ${gpio_number}    1

Drive GPIO low
    [Documentation]  Takes GPIO number as an argument. Sets it to output and drives low.
    [Arguments]    ${gpio_number}
    Set GPIO value    ${gpio_number}    0

Power On
    Drive GPIO high    199

Power Off
    Drive GPIO low    199

Open Connection and Log In
    [Documentation]    Open SSH connection with ip passed as argument and log
    ...                in to system.
    [Arguments]    ${ip}    ${alias}
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${ip}    alias=${alias}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}

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

Coldboot DUT
    [Documentation]    Hard reboot Device Under Test.
    Power Off
    Sleep    1 seconds
    Power On

Warmboot DUT
    [Documentation]    Soft reboot Device Under Test.
    Telnet.Execute Command    reboot\n
