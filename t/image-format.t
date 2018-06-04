use strict;
use warnings;
use Test::More;

use MetaCPAN::Pod::XHTML;

my $parser = MetaCPAN::Pod::XHTML->new;

$parser->output_string( \(my $output = '') );
my $pod = <<'END_POD';
  =pod

  =for image https://metacpan.org/static/images/metacpan-logo.png

  =cut
END_POD
$pod =~ s/^  //mg;
$parser->parse_string_document($pod);

like $output, qr{<img src="https://metacpan.org/static/images/metacpan-logo.png" />};

done_testing;
