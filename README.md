## RTE board validation

This repository contains tests related to RTE board itself. Tests are written
in RobotFramework and may be executed manually or with support of RTE framework.

#### Virtualenv initialization and dependencies installation

```
git clone git@gitlab.com:3mdeb/rte/
cd
git submodule update --init --checkout
virtualenv -p $(which python2) robot-venv
source robot-venv/bin/activate
./install_libs.sh
```

#### Virtualvenv deactivation

`deactivate`

#### Running test cases

Make sure that virtualvenv with robot framework is activated. General use:

`robot -L TRACE -v var_name:$VAR_VALUE ./foo/bar.robot`

For example, run `ssh_reboot.robot` test with variables set as follows:
* RTE ip = 192.168.3.125,
* DUT ip = 192.168.3.130,
* reboot repeat = 50 times,
* wait time for boot = 20 s.

`robot -L TRACE -v rte_ip:192.168.3.125 -v dut_ip:192.168.3.130 -v repeat:50 -v sleep:20 ssh_reboot.robot
`
