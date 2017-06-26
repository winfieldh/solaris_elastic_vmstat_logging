#!/usr/bin/perl

package Vmstat;
sub new {

   my $class = shift;
	
   my $self = {
      timestamp => shift,
      host => shift,
      r => shift,
      b  => shift,
      swpd => shift,
      free => shift,
      buff => shift,
      cache => shift,
      si => shift,
      so => shift,
      bi => shift,
      bo => shift,
      in => shift,
      cs => shift,
      us => shift,
      sy => shift,
      id => shift,
      wa => shift,
      st => shift
   };
	
   bless $self, $class;
   return $self;
}

sub TO_JSON { return { %{ shift() } }; }

package main;
use JSON;
use Sys::Hostname;
use Scalar::Util 'looks_like_number';
use POSIX;

my $eshost = "172.16.1.149";
my $esport = "9200";
my $esindex = "vmstat_linux";
#my $esindex = "vmstat_sol";

my $JSON = JSON->new->allow_nonref;
$JSON->convert_blessed(1);

#grab vmstat data
my $vmstatdata = `vmstat 1 3 | tail -1`; 

#remove newline from end of line
chomp($vmstatdata ); 

#remove leading spaces
$vmstatdata =~ s/^\s+//; 

#substitute two or more spaces with single
$vmstatdata =~ s/ {2,}/ /g; 

#substitute single spaces with comma
$vmstatdata =~ s/ /,/g; 

#prepend hostname so can be used as filter in ES
$vmstatdata = hostname.",".$vmstatdata ; 

#prepend date timestamp
my $timestamp = POSIX::strftime("%Y-%m-%dT%H:%M:%S",localtime());
$vmstatdata = $timestamp.",".$vmstatdata ; 
print $vmstatdata,"\n";

#create array of vmstat data
my @dataarray = split(/,/,$vmstatdata );

#multiply each number by 1 to trick perl to seeing integer vs character - not pretty but functional
#Otherwise data goes to ES as text
foreach my $x (0..scalar(@dataarray)) {
	if (looks_like_number($dataarray[$x])){
		$dataarray[$x] = $dataarray[$x] * 1;
		}
	}

my $v = new Vmstat(@dataarray);

my $json = $JSON->encode($v);
print "JSON: ".$json;

#POST the json to elasticsearch
my $results = `curl -XPOST '$eshost:$esport/$esindex/external/?pretty' -H 'Content-Type: application/json' -d \'$json\'`;
print "$results\n";
