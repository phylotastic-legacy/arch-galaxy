package Bio::PhyloTastic::PruneOMatic;
use strict;
use warnings;
use Getopt::Long;
use Bio::Phylo::IO qw'parse unparse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';
use base 'Exporter';
our @EXPORT_OK = qw'run';

sub run {

	# process command line arguments
	my ( $infile, $taxa, $outfile );
	GetOptions(
		'infile=s'  => \$infile,
		'taxa=s'    => \$taxa,
		'outfile=s' => \$outfile,
	);
	
	# parse tree
	my ($tree) = @{ parse(
		'-file'       => $infile,
		'-format'     => 'adjacency',
		'-as_project' => 1,
	)->get_items(_TREE_) };
	
	# parse taxa
	my @taxa;
	{
		open my $fh, '<', $taxa or die $!;
		while(<$fh>) {
			chomp;
			push @taxa, $_;
		}
		close $fh;
	}
	
	# do the pruning
	my $pruned = $tree->keep_tips(\@taxa);
	
	# open handle
	open my $fh, '>', $outfile or die $!;
	
	# print output
	print $fh unparse( '-format' => 'adjacency', '-phylo' => $tree );

}

1;
