package Bio::PhyloTastic;
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Logger;
use Bio::Phylo::IO qw'parse unparse';
use Bio::Phylo::Util::Exceptions 'throw';

# release number
our $VERSION = '0.1';

# Bio::Phylo::Util::Logger
my $log;
sub _log { $log }

# instantiate factory
my $fac = Bio::Phylo::Factory->new;
sub _fac { $fac };

# returns a hash for Getopt::Long
sub _get_default_args {
	my ( @infile, @deserializer, $outfile, $serializer, $verbose );
	return (
		'infile=s'       => \@infile,
		'deserializer=s' => \@deserializer,
		'serializer=s'   => \$serializer,
		'outfile=s'      => \$outfile,
		'verbose=i'      => \$verbose,		
	);
}

# gets child class arguments
sub _get_args {
	my $class = shift;
	$log->info(ref($class). ' did not specify additional arguments');
	return ();
}

# runs the child class, receives list of projects, returns project
sub _run {
	throw 'NotImplemented' => "Not implemented!";
}

sub run {
	my $class = shift;
	my %args = ( $class->_get_default_args, $class->_get_args );
	push @ARGV, @_;	
	
	# process arguments
	GetOptions(%args);
	
	# instantiate logger
	$log = Bio::Phylo::Util::Logger->new(
		'-level' => ${ $args{'verbose=i'} },
		'-class' => $class,
	);
	
	# parse projects
	my @projects;
	for my $i ( 0 .. $#{ $args{'infile=s'} } ) {
		push @projects, parse(
			'-format' => $args{'deserializer=s'}->[$i],
			'-file'   => $args{'infile=s'}->[$i],
			'-as_project' => 1,
		);
	}
	
	# run child class
	my $project = $class->_run(@projects);
	
	# client wants stringified
	if ( ${ $args{'outfile=s'} } ) {
		my $string = unparse(
			'-format' => ${ $args{'serializer=s'} },
			'-phylo'  => $project,
		);
		
		# to standard out
		if ( ${ $args{'outfile=s'} } eq '-' ) {
			print $string;
		}
		
		# to file
		else {
			open my $fh, '>', ${ $args{'outfile=s'} } or die $!;
			print $fh $string;
		}
	}
	else {
		return $project;
	}
}

1;