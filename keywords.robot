*** Keywords ***

Open Connection and Log In
    [Documentation]    Open SSH connection with ip passed as argument and log
    ...                in to system.
    [Arguments]    ${ip}
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${ip}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}

Reboot RTE
    [Documentation]    Reboots Remote Testing Environment.
    SSHLibrary.Start Command    reboot
