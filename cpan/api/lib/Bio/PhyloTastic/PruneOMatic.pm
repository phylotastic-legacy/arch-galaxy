package Bio::PhyloTastic::PruneOMatic;
use strict;
use warnings;
use Bio::Phylo::Util::CONSTANT ':objecttypes';
use base 'Bio::PhyloTastic';

# we will need this argument later on
my $taxa;

sub _get_args {	
	my $serializer = 'adjacency';
	return (
		'taxa=s'         => \$taxa,
		'deserializer=s' => [ 'adjacency' ],
		'serializer=s'   => \$serializer,
	);
}

sub _run {
	my ( $class, $project ) = @_;
	
	# parse tree
	my ($tree) = @{ $project->get_items(_TREE_) };
	
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
	
	# return result
	return $pruned;
}

1;
