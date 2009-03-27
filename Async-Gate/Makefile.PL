use inc::Module::Install;

name     'Async-Gate';
all_from 'lib/Async/Gate.pm';
author   'Pedro Melo <melo@cpan.org>';

build_requires 'Test::More';
build_requires 'Test::Deep';
build_requires 'Test::Exception';

auto_install;

WriteAll;

