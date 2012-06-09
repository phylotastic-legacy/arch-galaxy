#!/usr/bin/perl
use strict;

# process command line argument
my $tool = shift;

# create package name
my $package = "Bio/PhyloTastic/$tool.pm";
my $class = "Bio::PhyloTastic::$tool";

# try to load
eval { require $package };
if ( $@ ) {
	die <<"ERROR";
==================================== ERROR =====================================
FAILED TO RUN $tool
================================= EXPLANATION ==================================
The perl package Bio::PhyloTastic (or one of its dependencies) was not installed
correctly. This issue should be resolved by re-installing that package from the
comprehensive perl archive network (cpan.org), which is best done from the
command line:

	\$ sudo perl -MCPAN -e 'install Bundle::PhyloTastic'

================================================================================
The error that was issued when attempting to run the $tool tool was:
$@
================================================================================
ERROR
}

# run the tool
$class->run;