package Bio::PhyloTastic::PhyleMerge;
use strict;
use warnings;
use Getopt::Long;
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Logger;
use Bio::Phylo::IO qw'parse unparse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

# instantiate factory object
my $fac = Bio::Phylo::Factory->new;

# if true, names are stripped of single and double quotes
my $unquote;

# if provided a string, that string (e.g. _) is replaced with quotes
my $whitespace;

# number of parts to keep
my $parts;

# Bio::Phylo::Util::Logger
my $log;

sub run {
			
	# process command line arguments
	my ( @infiles, @deserializers, $outfile, $serializer, $verbose );
	GetOptions(
		'infile=s'       => \@infiles,
		'deserializer=s' => \@deserializers,
		'outfile=s'      => \$outfile,
		'serializer=s'   => \$serializer,
		'unquote+'       => \$unquote,
		'whitespace=s'   => \$whitespace,
		'parts=i'        => \$parts,
		'verbose+'       => \$verbose,
	);
	
	# instantiate logger
	$log = Bio::Phylo::Util::Logger->new(
		'-level' => $verbose,
		'-class' => __PACKAGE__,
	);
	
	# create merged object
	my $merged_project = $fac->create_project;
	$log->info('created new merger object');
		
	# parse files, add data to merged project
	parse(
		'-format'  => $deserializers[$_],
		'-file'    => $infiles[$_],
		'-project' => $merged_project,
	) for 0 .. $#infiles;
	$log->info('parsed '.scalar(@infiles).' input files');
	
	# extract all taxa blocks
	my @taxa = map { $_->_type == _TAXA_ ? $_ : $_->make_taxa } @{ $merged_project->get_entities };
	$merged_project->delete($_) for @taxa;
	$log->info('number of non-taxa blocks in project: '.scalar @{ $merged_project->get_entities });
	$log->info('number of taxa blocks to merge: '.scalar @taxa);
	
	# normalize names
	$_->visit(\&nameprocessor) for @taxa;
	$log->info('cleaned up taxa names');
	
	# merge the taxa blocks
	my $merged_taxa = $taxa[0]->merge_by_name( @taxa[1..$#taxa] );
	$merged_project->visit(sub{shift->set_taxa($merged_taxa)});	
	$merged_project->insert($merged_taxa);	
	
	# serialize object
	my $string = unparse(
		'-format' => $serializer,
		'-phylo'  => $merged_project,
	);
	
	# write output
	open my $fh, '>', $outfile or die $!;
	print $fh $string;
}

# cleans up taxon names before attempting merge
sub nameprocessor {
	my $taxon = shift;
	my $name = $taxon->get_name;
	
	# convert something (e.g. underscores) to spaces
	if ( $whitespace ) {
		$name =~ s/\Q$whitespace\E/ /g;
	}
	
	# strip quotes
	if ( $unquote ) {
		$name =~ s/['"]//g;
	}
	
	# keep $parts words
	if ( $parts ) {
		my @parts = split /\s/, $name;
		$name = join ' ', @parts[ 0 .. $parts - 1];
	}
	
	# assign clean name
	$taxon->set_name( $name );
}



1;