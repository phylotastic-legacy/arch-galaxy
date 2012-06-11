#!perl
# $Id: pod.t 838 2009-03-04 20:47:20Z rvos $
use Test::More;
plan skip_all => 'env var TEST_AUTHOR not set' if not $ENV{'TEST_AUTHOR'};
eval "use Test::Pod 1.14";
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
