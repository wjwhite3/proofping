#!/usr/bin/perl

########################################################
# Why Hello there. I'm JThree.pm
# I'm a dumping ground for commonly used tidbits
#
# To use me, put me in the same directory with the script
# you're writing, and put the following at the top of
# said script:
#
# use FindBin qw($Bin);
# use lib "$Bin";
# use JThree;
#
#version 0.01
########################################################
package JThree;
use Storable qw(dclone);
use Exporter;

our @ISA = qw( Exporter );
our @EXPORT_OK = qw(logHash msg amsg hmsg aohmsg);
our @EXPORT = qw(logHash msg amsg hmsg aohmsg);

sub logHash{
	##USAGE = logHash($filename, \@columns, $delimiter, $appendIndex
	# where
	#	$filename is the filename
	#	\@columns is an array of column titles for the long, passed by ref
	#	$delimiter is the delimiter used in your log file
	#	#appendIndex is a t/f value for if you want to add an index key/value pair to the hash

	my $filename = $_[0];
	my @keys = @{$_[1]};		#dereference array
	my $delimiter = $_[2];
	my $appendIndex = $_[3];
		
	my $loglines;	#this has to be outside the loop or its private to the loop apparently
	open(TEXT,$filename) or die "cant open $filename";
	while(<TEXT>){
			#stuff the current line into an array
			chomp;
			push(@logLines,$_);
	}
	close(TEXT);
	
	my @values;
	my @result;
	my $index = 1;
	foreach my $thisLine (@logLines){
		@values = split(',', $thisLine);
		my %tempHash;
		foreach my $key (@keys){
			$val = shift(@values);
			$tempHash{$key} = $val;
		}
		if($appendIndex){
			$tempHash{'index'} = $index;
		}
		push(@result, dclone(\%tempHash));		#remember to use dclone to copy hashes in future. it works.
		undef %tempHash;
		
		$index++;
	}
	return \@result;
}

sub msg{
	print $_[0] . "\n";
}

sub amsg{
	#please pass arrays to me by reference
	my @array = @{$_[0]};
	foreach my $thing (@array){
		msg($thing);
	}
}

sub hmsg {
	#takes a hashref, prints the hash all pretty
	my %hash = %{$_[0]};		#deref hash
	my $first = 1;
	foreach my $key (keys %hash){
		if($first){msg("-----------------");}
		$value = $hash{$key};
		msg("$key => $value");
		msg("-----------------");
		if($first){$first = 0;}
	}
}

sub aohmsg{
	#this takes a ref to an array of hashes, formats the key/val pairs, and prints (hopefully)
	
	my @aoh = @{$_[0]};		#deref the array
	foreach my $hashRef (@aoh){
		%thisHash = %$hashRef;	#try to deref hashref
		hmsg(\%thisHash);
	}
}

1;	#i guess we're returning true for some reason or other