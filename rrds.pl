#!/usr/bin/perl

use strict;
use warnings;
use RRDs;

my $PATH = "./";
my $RRD = "$PATH"."rrd/demo.rrd";
my $RRD_GRAPH = "$PATH"."graph/demo_graph.png";

my $rand;
my $error;
my $interval = 1;

if( -e $RRD ) {
	print "unlink $RRD file.\n";
	unlink($RRD);
}

RRDs::create($RRD,
		"-s 1",
		"DS:mem:GAUGE:100:U:U", 
		"RRA:LAST:0.5:1:3600");
rrd_error(RRDs::error);
print "created $RRD file.\n";

while(1) {
	$rand = int(rand(100));
	RRDs::update($RRD, "N:$rand");
	rrd_error(RRDs::error);
	print "updated $RRD file, data is $rand.\n";

	my ($start, $step, $ds_names, $data) = 
		RRDs::fetch($RRD, "LAST", "-s", "N-3600", "-e", "N");
	rrd_error(RRDs::error);

#	rrd_fetch_dump($data);

	my ($result_arr, $xsize, $ysize) = 
		RRDs::graph ("$RRD_GRAPH",
				"--start", "N-3600",
				"--end", "N",
				"--width", "710", "--height", "200",
				"--title= Memory Usage",
				"--vertical-label= Memory usage rate(MB)",
				"DEF:memory=$RRD:mem:LAST",
				"LINE1:memory#FF0000:Memory\\t"
				);
	rrd_error(RRDs::error);
	print("created graph $RRD_GRAPH\n");
	print("<graph info.>\n");
	print("result_arr: $result_arr\n");
	print("xsize: $xsize\n");
	print("ysize: $ysize\n");

	print("<rrd info.>\n");
	rrd_info(RRDs::info($RRD));

	print("\n");

	sleep($interval);
}

sub rrd_error {
	($err) = @_;

	die "ERROR: $err\n" if $err;
}

sub rrd_fetch_dump {
	($data) = @_;

	foreach $line (@$data) {
		foreach $val (@$line) {
			$val = int($val);
			print "val: $val\n";
		}
	}
}

sub rrd_info {
	($rrd_info) = @_;

	foreach my $key (keys %$rrd_info) {
		print ("$key = $$rrd_info{$key}\n");
	}
}
