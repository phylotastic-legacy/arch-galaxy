package Bio::PhyloTastic::BabelPhysh;
use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use Bio::Phylo::IO qw'parse unparse';
use base 'Exporter';
our @EXPORT_OK = qw'run';

sub run {
	push @ARGV, @_;

	# process arguments
	my ( $infile, $deserializer, $outfile, $serializer );
	GetOptions(
		'infile=s'       => \$infile,
		'deserializer=s' => \$deserializer,
		'serializer=s'   => \$serializer,
		'outfile=s'      => \$outfile,
	);
	
	# read input
	my $project = parse(
		'-format'     => $deserializer,
		'-file'       => $infile,
		'-as_project' => 1,
	);
	
	# create output
	my $output = unparse(
		'-format' => $serializer,
		'-phylo'  => $project,
	);
	
	# open file handle
	open my $fh, '>', $outfile or die $!;
	
	# print output
	print $fh $output;

}

1;