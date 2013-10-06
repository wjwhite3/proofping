#!/usr/bin/perl

################################################################
#ProofPingParse
#
#See Proofping for version number.
################################################################
#Based on previous work, pingplotparse.pl, which worked on the
#output of PingPlotter for windows.
################################################################
#USAGE: ppp.pl logfile.txt
################################################################

#Read in the log from ProofPing
if(@ARGV)
{
	open (TXTFILE,@ARGV[0]) or die "Can't open file";
	while(<TXTFILE>) { push (@logText,$_); }
	close (TXTFILE) or die "can't close $fileName";
}
else{
	die "No filename specified \nUsage: ppp.pl logfile.txt";
}
################################################################
###INFO-GATHERING SECTION
################################################################

$numLogLines = scalar(@logText);		#determine how many ping results we have in the logflie

#determine ping target
@firstLine = split(/,/,$logText[0]);
$target = $firstLine[2];

#determine duration of log by timestamps
@lastLine = split(/,/,$logText[scalar(@logText)-1]);
$firstTime = $firstLine[0];
$lastTime = $lastLine[0];
#print "$firstTime \n";								#testing line remove me
#print "$lastTime \n";								#testing line remove me
$stampDuration = $lastTime - $firstTime + 1;
#print "according to timestamps, log duration is $stampDuration \n";

#loop through the log, doing various things
$index = 0;
$outFlag = 0;
$numDropped = 0;
foreach $line (@logText){
	#grab all the values from the current line for use
	($perlTime, $humanTime, $target, $ping) = split(/,/, $line);		#more fantastical?
	
	#get sum of all pings for average math
	$sumPings += $ping;
	
	#determine if the ping was successful or not.
	#should die if $ping contains something other than a * or an interger response time
	if($ping =~ m/\*/){
		$returned = 0;
	} elsif ($ping =~ m/^\d+$/){
		$returned = 1; 
	} else { die "Something's wrong in the latency column of $ARGV[0]"; }
	
	#keep a tally of packetloss
	unless ($returned) { $numDropped++;}
	
	#build the list of outages
		#this list will be two arrays: @outStarts and @outEnds
		#the index values in those arrays will correspond with the index values
		#in this log (starting with 0)
	if (!$returned and !$outFlag){
		#detected start of outage.
		$outFlag = 1;				#set the outFlag
		push(@outStarts, $index);	#record the start of the outage
	} elsif (!$returned and $outFlag) {
		#do nothing. outFlag is set and outage start has been recorded
	} elsif ($returned and !$outFlag){
		#do nothing. outFlag is correct, and end point doesnt need setting or has already been set.
	} elsif($returned and $outFlag) {
		$outFlag = 0;				#set outFlag to off
		push(@outEnds, $index);	#record outage end point
	}
	
	if ($index == $numLogLines - 1 and $outFlag){
		#we find ourselves at the end of the log. if the log ends on an outage condition
		#we need to use the $index counter to set the last line as the end of the outage
		#even though the outage might still be ongoing. Cant think of anything better to 
		#do at the moment
		push(@outEnds, $index);
		$logEndDuringOutage = 1;
	}
	
} continue {$index++;}	#dont forget to increment the index var

#sanity check number of outage starts and ends
if(scalar(@outStarts) != scalar(@outEnds)){ 
	#die "Number of outage start and end points don't match up. Something's Wrong\n";
	print "Number of outage start and end points don't match up. Something's Wrong\n";
	print "here are the starts\n";
	foreach(@outStarts){ print "$_ \n";}
	print "here are the ends\n";
	foreach(@outEnds){ print "$_ \n";}
}

#find out how long the log has been running
@firstLine = split(/,/,$logText[0]);
@lastLine = split(/,/, $logText[(scalar(@logText) - 1)]);
$startTime = @firstLine[0];
$lastTime = @lastLine[0];
$logSeconds = $lastTime - $firstTime;
$logMinutes = $logSeconds/60;
$logHours = sprintf("%.2f",($logMinutes/60));
$logDays = sprintf("%.2f",($logHours/24));

$avgPing = sprintf("%.2f",($sumPings/$numLogLines));

################################################################
###OUTPUT SECTION	
################################################################
print "------------------------------------------------------------------------------\n";
print "Proofping Stats for log file: $ARGV[0]\n";
print "------------------------------------------------------------------------------\n";
print "\n";
print "target is $target\n";
print "log is $numLogLines lines long\n";
print "log is $logHours hours ($logDays days) long\n";
print "average ping is $avgPing \n";
print "$numDropped packets dropped \n";
$pctPacketLoss = sprintf "%.2f", ($numDropped/$numLogLines)*100;		#rnd to 2 dec places
print "$pctPacketLoss% packet loss\n";
if($logEndDuringOutage){print "The log ended during an outage\n";}
print "Detected " . scalar(@outStarts) . " outage periods\n";


#Determine and print outage information
###Note: it'd be nice to separate the gathering and output of this info from one another###
###		maybe stuff these lines in an array, move that logic above the output section, and then
###		just loop through and print the array contents down here. ###
print "\n\n\nOutage List\n";
$index = 0;
foreach $start (@outStarts){
	$end = $outEnds[$index];
	
	@outStartLine = split(/,/, $logText[$start]);
	@outEndLine = split(/,/, $logText[$end]);
	
	$startTime = $outStartLine[1];	#humanreadable
	$endTime = $outEndLine[1];		#human readable too
	$duration = $outEndLine[0] - $outStartLine[0] ;		#duration in seconds
	$pDuration = $end - $start;							#duration in packets
	
	print "------------------------------------------------------------------------------\n";
	print "Outage from $startTime to $endTime ($duration seconds). \nLost $pDuration packets\n";
	
	$index++;
}


#NEXT ADDITION: NEEDS TO LIST OUTAGES AND DURATIONS, MAYBE WITH AN OPTION TO FILTER OUT
#OUTAGES BASED ON DURATION (EG DONT LIST UNDER 5 SECONDS)


