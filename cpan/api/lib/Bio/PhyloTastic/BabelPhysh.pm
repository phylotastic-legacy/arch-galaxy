package Bio::PhyloTastic::BabelPhysh;
use strict;
use warnings;
use Bio::Phylo::IO qw'parse unparse';
use base 'Bio::PhyloTastic';

=head1 NAME

Bio::PhyloTastic::BabelPhysh - Converts between common phylogenetic file formats

=head1 SYNOPSYS

 phylotastic BabelPhysh -i <infile> -d <informat> -o <outfile> -s <outformat>

=head1 DESCRIPTION

This translates between commonly used file formats.

=head1 OPTIONS AND ARGUMENTS

=over

=item -i infile

An input file. Required.

=item -d informat

An input format, including NEXUS, Newick, NeXML, PhyloXML, TaxList. Required.

=item -o outfile

An output file name. If '-', prints output to STDOUT. Required.

=item -s outformat

An output format, including NeXML, TaxList. Required.

=back

=cut

sub _get_args { return () }

sub _run {
	my ( $class, $project ) = @_;
	return $project;
}

1;