#!/usr/bin/perl
use DBI;

#my @drivers = DBI->available_drivers();
#
#foreach my $driver (@drivers){
#	print "Driver: $driver\n";
##	my @datasources = DBI->data_sources($driver);
##	foreach my $datasource (@datasources){
##		print "Datasource is $datasource\n";
##	}
#	print "\n";
#}

my $dbh = DBI->connect("dbi:CSV:f_dir=.");
$dbh->{'csv_tables'}->{'short.txt'} = {'col_names' => ['perltime', 'humantime', 'target', 'ping']};
my $sth = $dbh->prepare("SELECT * FROM short.txt");
$sth->execute();

while(($perltime, $humantime, $target, $ping) = $sth->fetchrow_array()){
	print "perltime is $perltime, target is $target, $ping was the ping\n";
}

##
## This is here just to prove to myself that sql queries on CSV work. is it useful? i don't know
##
