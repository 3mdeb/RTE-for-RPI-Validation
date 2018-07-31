## RTE HAT validation

This repository contains tests related to RTE HAT. Tests are written in
RobotFramework and may be executed manually or with the support of RTE framework.

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

### RTE Validation test suite

#### Available test cases (`RTE_validation.robot`):
* `-t SSH*` - SSH service validation after coldboot/warmboot,
* `-t USB*` - USB port validation (plug 2 x USB storages into J6 and J8),
* `-t RS232*` - RS232 communication test in both directions (connect both RTE
  with NULL modem RS232 cable),
* `-t GPIO*` - GPIO loopback validation (connect 4 pins on J10 header to
  corresponding 4 GPIO pins on DUT J10 header).

To run `RTE_validation.robot` test suite it's required to set `rte_ip` ,`dut_ip`
(ip address of RTE Under Test) and `repeat` (number of reboots, default=20)
variables directly in command line, e.g.:

`robot -L TRACE -v rte_ip:192.168.3.105 -v dut_ip:192.168.3.107 -v repeat:50 RTE_validation.robot`

To run specific tests from test suite type (e.g. interfaces validation without
SSH service test cases):

`robot -L TRACE -v rte_ip:192.168.3.105 -t USB* -t RS232* -t GPIO* RTE_validation.robot`

### Yocto regression test suite

#### Available test cases (`regression_tests.robot`):
* `-t 1*` - system boot validation after coldboot (1.1) and warmboot (1.2),  
* `-t 2*` - watchdog validation: manual reset via watchdog (2.1) and fork-bomb
  test for WDT (2.2),
* `-t 3*` - CBFStool (3.1) and IFDtool (3.2) test cases.

To run `regression_tests.robot` test suite it's required to set `rte_ip`,
`dut_ip` (ip address of RTE Under Test), `repeat` (number of reboots,
default=20), `cbfs_file` (path to file for CBFStool test) and `ifd_file` (path
to file for IFDtool test) variables directly in command line, e.g.:

```
robot -v rte_ip:192.168.3.105 -v dut_ip:192.168.3.107 -v repeat:20 -v cbfs_file:apu2_v4.8.0.2.rom -v ifd_file:libretrend_firmware.bin regression_tests.robot
```

#### Additional information

These test suites use `13542` redirection port specified in `variables.robot`.
If there is a problem with telnet / ser2net connection, check the content of
`/etc/ser2net.conf`. Port declarations are listed at the end of the file. It
should look like this:

```
13541:telnet:600:/dev/ttyS1:115200 8DATABITS NONE 1STOPBIT
13542:telnet:600:/dev/ttyUSB0:115200 8DATABITS NONE 1STOPBIT
```
