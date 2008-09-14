use inc::Module::Install;

RTx('RTx-Tags');
author('Jerrad Pierce <jpierce@cpan.org>');
abstract('Tag cloud');
license('perl');

requires 'HTML::TagCloud'      => 0;

WriteAll();

sub MY::postamble {
    package MY;
    "\npredist: all\n" .
    "\tpod2readme  lib/RTx/Tags.pm > README\n"
}
