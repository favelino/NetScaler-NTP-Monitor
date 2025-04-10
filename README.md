# NetScaler-NTP-Monitor

NTP Monitor Script for NetScaler ADC

Why monitor NTP Stratum?	
NTP Stratum indicates how many hops away an NTP server is from a primary time source. Lower values (1-15) are reliable, while a stratum of 16 usually means the server is unsynchronized or unreachable. Monitoring this helps ensure accurate time synchronization across your infrastructure.
How the Script Works	

This simple script automatically checks the NTP service running on the monitored server (using its service IP directly) and verifies the server’s stratum level using ntpdate in query-only mode (ntpdate -q).

Here's the core logic:	
Retrieve Service IP Automatically: The script pulls the service IP directly from the NetScaler service.	

Run NTP Query: It uses Perl's backtick operator to execute the ntpdate command to query the server.	

Parse Output: The script extracts the stratum number from the command output.	

Evaluate Response:	

If the stratum is between 1 and 15, it means the NTP server is healthy, and the script reports success.	

If the stratum is 16, the server is unsynchronized or unreachable, so it reports failure.	

Any other unexpected output also results in a failure notification.	

Deploying the Script	

Save this Perl script below  in your NetScaler's /nsconfig/monitors/ directory. 	

Provide the proper permissions to execute the Script from NetScaler Shell	

chmod +x  /netscaler/monitors/stratum.pl	


NetScaler CLI Commands

Use the commands below to create the monitor in the NetScaler CLI:

Make sure to let increase the interval time, in this case it was increased to 10 and the response timeout to 5. The default timers don't work.

add lb monitor ntp-stratum-monitor USER -scriptName stratum.pl -dispatcherIP 127.0.0.1 -dispatcherPort 3013 -LRTM DISABLED -interval 10 -resptimeout 5

