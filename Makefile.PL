use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Swishetest',
    VERSION_FROM      => 'Swishetest.pm', # finds $VERSION
    PREREQ_PM         => {
		#SWISH::API => 0.0,	# won't work on swish-e 2.4.4, gets "Can't locate auto/SWISH/API/VERSION.al"
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'Swishetest.pm', # retrieve abstract from module
       AUTHOR         => 'Josh Rabinowitz <joshr@nonet>') : ()),
);

sub MY::install {
	return "install:\n\techo 'not intended to be installed'\n";
}
#sub MY::clean {
#	return "clean:\n\t\@rm -rf index/*.index index/*.index.prop";
#}
