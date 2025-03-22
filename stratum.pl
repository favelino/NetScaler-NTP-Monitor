#!/usr/bin/perl -w
################################################################
## NTP Stratum Check Monitor for NetScaler v2.0
## Checks if the NTP server is alive by verifying its stratum level
## This version uses the service IP (first argument) automatically.
################################################################

use strict;
use Netscaler::KAS;

sub ntp_probe {
    # Expect at least one argument (the service IP)
    if (scalar(@_) < 1) {
        return (1, "Insufficient number of arguments");
    }
    
    # Use the service IP (first argument) as the NTP server address
    my $ntp_server = $_[0];
    
    # Validate input
    if (!defined $ntp_server || $ntp_server eq "") {
        return (1, "Error: NTP server not specified");
    }

    # Command to query the NTP server (using ntpdate in query-only mode)
    my $cmd = "/usr/sbin/ntpdate -q $ntp_server 2>&1";
    my $output = `$cmd`;
    my $exit_code = $? >> 8;   # Extract the actual exit code

    # Check if the command executed successfully
    if ($exit_code != 0) {
        return (1, "Error: ntpdate failed - $output");
    }

    # Parse the output for the stratum level
    if ($output =~ /stratum (\d+)/) {
        my $stratum = $1;
        # If the stratum is 16, the server is unsynchronized or unreachable
        if ($stratum == 16) {
            return (1, "NTP server $ntp_server is unreachable or unsynchronized, stratum $stratum");
        }
        # For a valid stratum (1-15), return success without a message
        elsif ($stratum >= 1 && $stratum <= 15) {
            return 0;
        }
        else {
            return (1, "Unexpected stratum level $stratum from NTP server $ntp_server");
        }
    } 
    else {
        return (1, "Error: Could not determine stratum from output - $output");
    }
}

# Register the probe subroutine with the KAS module
probe(\&ntp_probe);
