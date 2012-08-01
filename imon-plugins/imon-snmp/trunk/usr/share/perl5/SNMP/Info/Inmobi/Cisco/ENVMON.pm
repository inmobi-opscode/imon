# $Id$

package SNMP::Info::Inmobi::Cisco::ENVMON;

use strict;
use Exporter;
use SNMP::Info::Inmobi::Cisco;

use Data::Dumper;

@SNMP::Info::Inmobi::Cisco::ENVMON::ISA = qw/SNMP::Info Exporter/;
@SNMP::Info::Inmobi::Cisco::ENVMON::EXPORT_OK = qw//;

use vars qw/$VERSION %GLOBALS %MIBS %FUNCS %MUNGE/;

$VERSION = '2.06';

%MIBS = (
  'CISCO-ENVMON-MIB'  => 'ciscoEnvMonPresent',
);

%GLOBALS = (
);

%FUNCS = (
  # CISCO-ENVMON-MIB
  'ciscoEnvMonVoltageStatusDescr' => 'ciscoEnvMonVoltageStatusDescr',
  'ciscoEnvMonVoltageStatusValue' => 'ciscoEnvMonVoltageStatusValue',
  'ciscoEnvMonVoltageThresholdLow'  => 'ciscoEnvMonVoltageThresholdLow',
  'ciscoEnvMonVoltageThresholdHigh' => 'ciscoEnvMonVoltageThresholdHigh',
  'ciscoEnvMonVoltageLastShutdown'  => 'ciscoEnvMonVoltageLastShutdown',
  'ciscoEnvMonVoltageState' => 'ciscoEnvMonVoltageState',
  'ciscoEnvMonTemperatureStatusDescr' => 'ciscoEnvMonTemperatureStatusDescr',
  'ciscoEnvMonTemperatureStatusValue' => 'ciscoEnvMonTemperatureStatusValue',
  'ciscoEnvMonTemperatureThreshold' => 'ciscoEnvMonTemperatureThreshold',
  'ciscoEnvMonTemperatureLastShutdown'  => 'ciscoEnvMonTemperatureLastShutdown',
  'ciscoEnvMonTemperatureState' => 'ciscoEnvMonTemperatureState',
  'ciscoEnvMonFanStatusDescr' => 'ciscoEnvMonFanStatusDescr',
  'ciscoEnvMonFanState' => 'ciscoEnvMonFanState',
  'ciscoEnvMonSupplyStatusDescr'  => 'ciscoEnvMonSupplyStatusDescr',
);

%MUNGE = (
);

1;

# vim: set ts=2 sw=2 expandtab:
