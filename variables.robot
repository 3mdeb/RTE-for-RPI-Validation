*** Variables ***

${USERNAME}        root
${PASSWORD}        meta-rte
${http_port}       8000
${s2n_port}        13542
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
