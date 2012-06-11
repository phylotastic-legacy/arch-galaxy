package Bio::PhyloTastic::TaxTractor;
use strict;
use warnings;
use base 'Bio::PhyloTastic';

# these are used as "perl compatible regular expressions" to process
# the labels, so you could strip out accession numbers and such
my $search = ' ';
my $replace = ' ';

sub _get_args {
	my $serializer = 'taxlist';
	return (
		'search=s'     => \$search,
		'replace=s'    => \$replace,
		'serializer=s' => \$serializer,
	);
}

sub _run {		
	my ( $class, $project ) = @_;
	
	# fetch factory object
	my $fac = $class->_fac;
	
	# create merged taxa block
	my $merged_taxa = $fac->create_taxa;
	
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
	
	# create distinct taxa
	$merged_taxa->insert( $fac->create_taxon( '-name' => $_ ) ) for sort { $a cmp $b } keys %names;
	
	# return result
	return $merged_taxa;
}

1;