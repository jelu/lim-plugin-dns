use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Lim::Plugin::ZFM',
    AUTHOR              => q{Jerry Lundström <lundstrom.jerry@gmail.com>},
    VERSION_FROM        => 'lib/Lim/Plugin/ZFM.pm',
    ABSTRACT_FROM       => 'lib/Lim/Plugin/ZFM.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PREREQ_PM => {
        'Test::More' => 0,
        'common::sense' => 3,
        'Lim' => 0.12,
        'Scalar::Util' => 1
    },
    (! eval { ExtUtils::MakeMaker->VERSION(6.46) } ? () :
        (META_ADD => {
            resources => {
                homepage   => 'http://github.com/jelu/lim-plugin-zfm/wiki',
                repository => 'http://github.com/jelu/lim-plugin-zfm',
                bugtracker => 'http://github.com/jelu/lim-plugin-zfm/issues',
            },
        })
    ),
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Lim-Plugin-ZFM-*' },
);
