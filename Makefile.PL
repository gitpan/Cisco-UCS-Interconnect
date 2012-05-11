use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Cisco::UCS::Interconnect',
    AUTHOR              => q{Luke Poskitt <ltp@cpan.org>},
    VERSION_FROM        => 'lib/Cisco/UCS/Interconnect.pm',
    ABSTRACT_FROM       => 'lib/Cisco/UCS/Interconnect.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Cisco-UCS-Interconnect-*' },
);
