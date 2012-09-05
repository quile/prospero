use inc::Module::Install;

name     'Prospero';
all_from 'lib/Prospero.pm';
author   q{Kyle Dawkins <info@kyledawkins.com>};
license  'MIT';

requires 'Object::KeyValueCoding' => '0.98';
requires 'Try::Tiny';
requires 'File::ShareDir';
requires 'Text::Unaccent::PurePerl';

build_requires 'Test::More';
build_requires 'Test::Class';

auto_install;

WriteAll;

