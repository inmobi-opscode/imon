# $Id$

package SNMP::Info::Inmobi;

use strict;
use Exporter;
use SNMP::Info;

@SNMP::Info::Inmobi::ISA = qw/SNMP::Info Exporter/;
@SNMP::Info::Inmobi::EXPORT_OK = qw//;

use vars qw/$VERSION %MIBS %FUNCS %GLOBALS %MUNGE/;

$VERSION = '2.06';

%MIBS = (
);

%FUNCS = (
);

%GLOBALS = (
);

%MUNGE = (
);

return 1;

# vim: set ts=2 sw=2 expandtab:
