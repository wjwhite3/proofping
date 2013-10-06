#!/usr/bin/perl


################ PROOFPING #####################
# Version 0.05dev
# Joe White III
# Project Started 9/16/13
#
#	This small script is to output the date, and
#	the response to a ping of a specified host,
#	and to do so in a loggable way.
#	
#	Usage: proofping.pl > logfile.txt
#
#	Probably the best way to use this is to
#	first run proofping.pl > logfile.txt
#	Then, run mon.pl logfile.txt in another
#	command window
#	
################################################



################################################
# Config Section
################################################

#####Constants#######
$osxStripString = 'PING|statistics|packets|round|^\s*$';
$win7StripString = 'Pinging|statistics|Packets|Approximate|Minimum|^\s*$';
$osxCommand = 'ping -c 1 -t 1000';
$win7Command = 'ping -n 1 -w 1000';
#####Variables#######

$target = "8.8.8.8";					#This is what gets pinged
#$stripString = $win7StripString;		#this is what gets stripped out of the ping output
#$command = $win7Command;				#this is the command and arguments for ping
$delay = 1;								#how many seconds to wait between pings

#####AutoConfig#######

if		($^O =~ /darwin/) 	{ $stripString = $osxStripString; $command = $osxCommand; }
elsif	($^O =~ /MSWin32/)	{ $stripString = $win7StripString; $command = $win7Command;}
else	{ die "cannot determine OS\n"; }

#print "command is $command\nstripstring is $stripString\n";

################################################
# /Config Section
################################################


while(1==1)
{
	@result = `$command $target`;

	foreach $line (@result)
	{
		#strip unwanted lines, including blank lines, from output
		if ($line !~ /$stripString/)
		{
			$timeStamp = localtime(time());
			chomp($line);
			#print $line . "\n"; #for testing only
			if($line =~ m/time=(.*?)ms/){						#this pulls out just the latency number for each ping result
				$latency = sprintf("%.0f",$1);					#and stuffs it into $latency (rounded b/c i don't need it that precise ffs..)
			}
			if($line !~ m/time=(.*?)ms/){
				$latency = '*'
			}
			#print $line . "\n";
			print join(',' , time(), $timeStamp, $target ,$latency) . "\n";
			sleep($delay);
		}
	}

}

