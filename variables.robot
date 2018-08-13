*** Variables ***

${USERNAME}        root
${PASSWORD}        meta-rte
${http_port}       8000
${s2n_port1}       13541
${s2n_port2}       13542
${dut_user}        root
${dut_pwd}         meta-rte

# ssh variables
${repeat}          20

# usb variables
${usb1}            Bus 004
${usb2}            Bus 005

# serial variables
${rs232}           /dev/ttyS1

# gpio variables (J10)
${gpio1}           gpio400
${gpio2}           gpio401
${gpio3}           gpio402
${gpio4}           gpio403
@{gpio_list}    ${gpio1}    ${gpio2}    ${gpio3}    ${gpio4}

# Yocto regression
${fw_path}        /tmp/firmware
${new_runtime}     5
${old_runtime}     0
${err1}            Kernel panic
${err2}            Sending NMI from CPU
${err3}            Unable to handle kernel NULL pointer dereference
@{error_list}    ${err1}    ${err2}    ${err3}
