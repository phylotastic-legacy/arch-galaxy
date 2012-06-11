package Bio::PhyloTastic::TaxTractor;
use strict;
use warnings;
use Getopt::Long;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::Logger ':levels';

sub run {
		
	# these are used as "perl compatible regular expressions" to process
	# the labels, so you could strip out accession numbers and such
	my $search = '';
	my $replace = '';

	# process command line arguments
	my ( $infile, $format, $outfile );
	my $verbosity = DEBUG;
	GetOptions(
		'infile=s'  => \$infile,
		'format=s'  => \$format,
		'search=s'  => \$search,
		'replace=s' => \$replace,
		'outfile=s' => \$outfile,
		'verbose+'  => \$verbosity,
	);
	
	# instantiate logger
	my $log = Bio::Phylo::Util::Logger->new(
		'-level' => $verbosity,
		'-class' => __PACKAGE__,
	);
	
	# parse infile
	my $project = parse(
		'-format' => $format,
		'-file'   => $infile,
		'-as_project' => 1
	);
	
	# compile hash set of distinct names, that are
	# processed using s/$search/$replace/
	my %names;
	for my $block ( @{ $project->get_entities } ) {
		my $taxa;
		if ( $block->can('make_taxa') ) {
			$taxa = $block->make_taxa;
		}
		else {
			$taxa = $block;
		}
		$taxa->visit(sub{
			my $name = shift->get_name;
			$name =~ s/$search/$replace/g;
			$names{$name} = 1
		});
	}
	
	# print output
	{
		open my $fh, '>', $outfile or die $!;
		print $fh join "\n", keys %names;
		close $fh;
	}
}

1;