## RTE HAT validation

This repository contains tests related to RTE HAT. Tests are written in
RobotFramework and may be executed manually or with the support of RTE
framework.

#### Virtualenv initialization and dependencies installation

```
git clone git@gitlab.com:3mdeb/rte/validation
cd validation
git submodule update --init --checkout
virtualenv -p $(which python2) robot-venv
source robot-venv/bin/activate
pip install -r requirements.txt
```

#### Virtualvenv deactivation

`deactivate`

#### Running test cases

Make sure that virtualvenv with robot framework is activated. General use:

`robot -L TRACE -v var_name:$VAR_VALUE ./foo/bar.robot`

### RTE Validation test suite

#### Available test cases and required connections (`RTE_validation.robot`):
* `-t SSH*` - SSH service validation after coldboot/warmboot,
* `-t USB*` - USB port validation (plug 2 x USB storages into J6 and J8),
* `-t RS232*` - RS232 loopback communication (connect pin2 (RX) with pin3 (TX)
  on J14 DUT connector (DB9) via jumper wire),
* `-t GPIO*` - GPIO loopback validation (connect 4 pins on J10 header to
  corresponding 4 GPIO pins on DUT J10 header),
* `-t I2C*` - I2C interface validation (connect 4 pins on J9 header to
  corresponding pins on BMA220 sensor),
* `-t SPI*` - SPI interface validation. To perform this test case connect one
  APUx platform to DUT due to [this](https://gitlab.com/3mdeb/rte/docs/blob/master/docs/apus-connection-rte-0-5-3.md)
  instruction, but use RS232 null modem cable to connect APUx with RTE (DUT DB9
  port is needed for RS232 loopback validation).

> Make sure that ECDSA key fingerprint for `dut_ip` is set, otherwise `fw_file`
  won't be uploaded.

To run `RTE_validation.robot` test suite it's required to set `rte_ip` ,`dut_ip`
(ip address of RTE Under Test), `repeat` (number of reboots, default=20),
`platform` (PCEngines APUx, ex. apu4) and `fw_file` (coreboot ROM for APUx
flashing) variables directly in command line, e.g.:

`robot -L TRACE -v rte_ip:192.168.3.105 -v dut_ip:192.168.3.107 -v repeat:50 -v platform:apu4 -v fw_file:apu4_v4.8.0.2.rom  RTE_validation.robot`

To run specific tests from test suite type (e.g. loopback RS232 and GPIO
interfaces validation):

`robot -L TRACE -v rte_ip:192.168.3.105 -t RS232* -t GPIO* RTE_validation.robot`

### Yocto regression test suite

#### Available test cases (`regression_tests.robot`):
* `-t BOT*` - system boot validation after coldboot (1.1) and warmboot (1.2),  
* `-t WDT*` - watchdog validation: manual reset via watchdog (2.1) and fork-bomb
  test for WDT (2.2),
* `-t TOL*` - CBFStool (3.1) and IFDtool (3.2) test cases.

To run `regression_tests.robot` test suite it's required to set `rte_ip`,
`dut_ip` (ip address of RTE Under Test), `repeat` (number of reboots,
default=20), `cbfs_file` (path to file for CBFStool test) and `ifd_file` (path
to file for IFDtool test) variables directly in command line, e.g.:

```
robot -v rte_ip:192.168.3.105 -v dut_ip:192.168.3.107 -v repeat:20 -v cbfs_file:apu2_v4.8.0.2.rom -v ifd_file:libretrend_firmware.bin -v sw_image:<path_to_file> regression_tests.robot
```
> Make sure that ECDSA key fingerprint for `dut_ip` is set, otherwise `cbfs_file`
or `ifd_file` won't be uploaded.

#### Additional information

These test suites use `13542` redirection port specified in `variables.robot`.
If there is a problem with telnet / ser2net connection, check the content of
`/etc/ser2net.conf`. Port declarations are listed at the end of the file. It
should look like this:

```
13541:telnet:600:/dev/ttyS1:115200 8DATABITS NONE 1STOPBIT
13542:telnet:600:/dev/ttyUSB0:115200 8DATABITS NONE 1STOPBIT
```
