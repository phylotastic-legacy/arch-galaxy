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
 FAILED TO LOAD $class
================================= EXPLANATION ==================================
 The perl package $class (or one of its dependencies) 
 couldn't be loaded correctly. This is either because it hasn't been installed
 system-wide or because the environment variable PERL5LIB does not include the
 path to the lib folder of the cpan api.
================================================================================
  The error that was issued when attempting to run the $tool tool was:
$@
================================================================================
ERROR
}

# run the tool
$class->run;