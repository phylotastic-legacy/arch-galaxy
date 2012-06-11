This is a set of client classes that perform PhyloTastic services. The classes
are designed such that they can both be used inside scripts and invoked from the
command line.

This software is pre-alpha, it's just proof of concept. If you're brave, you can
try running:

    $ perl Makefile.PL

This should give you an overview of any prerequisites you're missing. If
everything looks OK you might add the lib folder to your $PERL5LIB environment
variable. Subsequently, you can run:

    $ make

This will create the phylotastic command line utility, which is in the script
folder. You might want to consider adding the script folder to your $PATH
environment variable.

Of course, you can also do:

    $ sudo make install

In which case you don't have to modify either environment variable (but then
this alpha code is installed system-wide).