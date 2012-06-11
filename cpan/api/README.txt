This is a set of client classes that perform PhyloTastic services. The classes
are designed such that they can both be used inside scripts and invoked from the
command line.

This software is pre-alpha, it's just proof of concept. If you're brave, you can
try running:

	perl Makefile.PL

This should give you an overview of any prerequisited you're missing. After
running the Makefile.PL you are able to run 'sudo make install', but you're
probably better off pointing $PERL5LIB to the lib/ folder, at least for the time
being.