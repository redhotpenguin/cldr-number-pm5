use utf8;
use strict;
use warnings;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 34;
use CLDR::Number;

my $cldr = CLDR::Number->new;
my $decf = $cldr->decimal_formatter;

is $decf->pattern('0'),        '0';
is $decf->pattern('00'),       '00';
is $decf->pattern('0.#'),      '0.#';
is $decf->pattern('0.##'),     '0.##';
is $decf->pattern('0.0'),      '0.0';
is $decf->pattern('0.00'),     '0.00';
is $decf->pattern('0.0#'),     '0.0#';
is $decf->pattern('#,0'),      '#,0';
is $decf->pattern('0,0'),      '0,0';
is $decf->pattern('#,#,#0'),   '#,#,#0';
is $decf->pattern('0,0,00'),   '0,0,00';

is $decf->pattern('.'),         '0';
is $decf->pattern(','),         '0';
is $decf->pattern(',.'),        '0';
is $decf->pattern(',,'),        '0';
is $decf->pattern('0.'),        '0';
is $decf->pattern('#'),         '0';
is $decf->pattern('#.'),        '0';
is $decf->pattern('#0'),        '0';
is $decf->pattern('#,0,,'),     '0';
is $decf->pattern('.#'),        '0.#';
is $decf->pattern('#.#'),       '0.#';
is $decf->pattern(',0'),        '#,0';
is $decf->pattern('#,#,0'),     '#,0';
is $decf->pattern('#,#'),       '#,0';
is $decf->pattern('##,0'),      '#,0';
is $decf->pattern('#,,0'),      '#,0';
is $decf->pattern('#,#,#0,'),   '#,#0';
is $decf->pattern(',#,#0'),     '#,#,#0';
is $decf->pattern('#,#,#,#0'),  '#,#,#0';
is $decf->pattern('#,##,#,#0'), '#,#,#0';
is $decf->pattern('0,00,0,0'),  '0000,0';
is $decf->pattern('0,0,0,00'),  '00,0,00';
is $decf->pattern('0,00,0,00'), '000,0,00';
