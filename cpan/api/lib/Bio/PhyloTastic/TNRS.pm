package Bio::PhyloTastic::TNRS;
use strict;
use warnings;
use JSON;
use URI::Escape;
use Getopt::Long;
use Data::Dumper;
use LWP::UserAgent;
use Bio::Phylo::Util::Logger ':levels';
use Bio::Phylo::IO qw'parse unparse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

# URL for the taxonomic name resolution service
my $TNRS_URL = 'http://128.196.142.27:3000/submit';

# process command line arguments
my $verbosity = DEBUG;
my $timeout   = 60;
my $wait      = 5;

# Bio::Phylo::Util::Logger
my $log;

# output file to write to
my $outfile;

sub run {

	my $infile;
	GetOptions(
		'infile=s'  => \$infile,
		'outfile=s' => \$outfile,
		'verbose+'  => \$verbosity,
		'timeout=i' => \$timeout,
		'wait=i'    => \$wait,
	);
	
	# instantiate logger
	$log = Bio::Phylo::Util::Logger->new(
		'-level' => $verbosity,
		'-class' => __PACKAGE__,
	);
	
	# parse input
	my $project = parse(
		'-format'     => 'taxlist',
		'-file'       => $infile,
		'-as_project' => 1,
	);
	$log->info("parsed data from $infile");
	
	# get taxa
	my ($taxa) = @{ $project->get_items(_TAXA_) };
	$log->info("extracted taxa");
	
	# fetch names from taxon objects
	my %taxon_for_name = map { $_->get_name => $_ } @{ $taxa->get_entities };
	
	# do the request
	my $result = fetch_url( $TNRS_URL, 'post', 'query' => join "\n", keys %taxon_for_name ); # this is a redirect
	my $obj = decode_json($result);
	
	# start polling
	while(1) {
		sleep $wait;
		my $result = fetch_url($obj->{'uri'},'get');
		my $obj = decode_json($result);
		if ( $obj->{'names'} ) {
			$log->debug(Dumper($obj));
			process_result($result);
			exit(0);
		}
	}

}

# fetch data from a URL
sub fetch_url {
	my ( $url, $method, %form ) = @_;
	$log->info("going to fetch $url");
	
	# instantiate user agent
	my $ua = LWP::UserAgent->new;
	$ua->timeout($timeout);
	$log->info("instantiated user agent with timeout $timeout");
	
	# do the request on LWP::UserAgent $ua
	my $response = $ua->$method($url,\%form);
	
	# had a 200 OK
	if ( $response->is_success ) {
		$log->info($response->status_line);
		my $content = $response->decoded_content;
		return $content;
	}
	else {
		$log->error($response->status_line);
		die $response->status_line;
	}	
}

# parses the final TNRS result, maps back to input taxa, creates output
sub process_result {
	my $content = shift;
	
	# parse result
	my ($tnrs_taxa) = @{ parse(
		'-format' => 'tnrs',
		'-string' => $content,
		'-as_project' => 1,
	)->get_items(_TAXA_) };
	$log->info("retrieved ".$tnrs_taxa->get_ntax. " results");
	
	# identify predicates to write out to adjacency table
	my @predicates;
	for my $meta ( @{ $tnrs_taxa->get_meta } ) {
		if ( my $source = $meta->get_object('tnrs:source') ) {
			push @predicates, "tnrs:${source}";
		}
	}
	
	# open output handle
	open my $fh, '>', $outfile or die $!;
	
	# print header
	print $fh 'name';
	if ( @predicates ) {
		print $fh "\t";
		print $fh join "\t", @predicates;
	}
	print $fh "\n";
	
	# print taxon metadata as tab-delimited table
	$tnrs_taxa->visit(sub {
		my $taxon = shift;
		print $fh $taxon->get_name;
		if ( @predicates ) {
			print $fh "\t";
			my @values = map { $taxon->get_meta_object($_) || '' } @predicates;
			print $fh join "\t", @values;
		}
		print $fh "\n";
	});
}

1;