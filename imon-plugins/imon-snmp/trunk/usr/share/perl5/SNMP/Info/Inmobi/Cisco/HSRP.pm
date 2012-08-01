# $Id$

package SNMP::Info::Inmobi::Cisco::HSRP;

use strict;
use Exporter;
use SNMP::Info::Inmobi::Cisco;

use Data::Dumper;

@SNMP::Info::Inmobi::Cisco::HSRP::ISA = qw/SNMP::Info Exporter/;
@SNMP::Info::Inmobi::Cisco::HSRP::EXPORT_OK = qw//;

use vars qw/$VERSION %GLOBALS %MIBS %FUNCS %MUNGE/;

$VERSION = '2.06';

%MIBS = (
  'CISCO-HSRP-MIB'  => 'cHsrpConfigTimeout',
);

%GLOBALS = (
);

%FUNCS = (
  # CISCO-HSRP-MIB
  'cHsrpGrpStandbyState'  => 'cHsrpGrpStandbyState',
);

%MUNGE = (
);

1;

# vim: set ts=2 sw=2 expandtab:
