use 5.006001;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'XML::Feed::JavaScript',
    VERSION_FROM      => 'lib/XML/Feed/JavaScript.pm',
    PREREQ_PM         => {
		XML::Feed      => 0.05,
		Encode         => 0,
		Encode::compat => 0.07,
		HTML::Template => 0,
	},
);
