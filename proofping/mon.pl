#!/usr/bin/perl

################################################
# Mon.PL - The ProofPing Monitor
################################################
# Usage: mon.pl logfile.txt
################################################

print "Welcome to mon.pl\nPlease wait a few seconds while I start up\n";

while (1==1){

	
	
	$result = `ppp.pl $ARGV[0]`;
		
	print "\nREFRESHING\n";
	sleep (1);
	if($^O eq 'MSWin32') { system ('cls'); } else { system('clear'); }	#os independent clear-screen command
	print "\n Monitoring ProofPing output. \n Screen refreshes every 10 seconds\nctrl-c to stop.\n\n\n";
	print $result;
}