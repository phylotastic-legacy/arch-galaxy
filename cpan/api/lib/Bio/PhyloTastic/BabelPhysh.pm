package Bio::PhyloTastic::BabelPhysh;
use strict;
use warnings;
use Bio::Phylo::IO qw'parse unparse';
use base 'Bio::PhyloTastic';

sub _get_args { return () }

sub _run {
	my ( $class, $project ) = @_;
	return $project;
}

1;