## RTE HAT validation

This repository contains tests related to RTE HAT. Tests are written in
RobotFramework and may be executed manually or with support of RTE framework.

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

For example, run `RTE_validation.robot` test suite with variables set as
follows:
* RTE ip = 192.168.3.105,
* DUT ip = 192.168.3.107,
* reboot repeat = 50 times,
* wait time for boot = 20 s.

`robot -L TRACE -v rte_ip:192.168.3.105 -v dut_ip:192.168.3.107 -v repeat:50 -v sleep:20 RTE_validation.robot`

To run specific tests from test suite type (e.g. interfaces validation without
SSH service test cases):

`robot -L TRACE -v rte_ip:192.168.3.105 -t USB* -t RS232* -t GPIO* RTE_validation.robot`

#### Available test cases (`RTE_validation.robot`):
* `-t SSH*` - SSH service validation after coldboot/warmboot,
* `-t USB*` - USB port validation (plug-in 2 x USB storages),
* `-t RS232` - RS232 communication test in both directions (connect both RTE
  with NULL modem RS232 cable),
* `-t GPIO` - GPIO loopback validation (connect 4 pins on J10 header to
  corresponding 4 GPIO pins on DUT J10 header).

#### Additional information

If there is a problem with telnet / ser2net connection, check the content of
`/etc/ser2net.conf`. Port declarations are specified at the end of the file. It
should look like this:

```
13541:telnet:600:/dev/ttyS1:115200 8DATABITS NONE 1STOPBIT
13542:telnet:600:/dev/ttyUSB0:115200 8DATABITS NONE 1STOPBIT
```
