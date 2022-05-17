use strict;
use warnings;
use Test::More;

my $class;
{
  package ParserWithExtraTargets;
  $class = __PACKAGE__;
  use Moo;
  extends 'Pod::Simple::XHTML';
  with 'Pod::Simple::Role::XHTML::WithAccurateTargets';
  with 'Pod::Simple::Role::XHTML::WithExtraTargets';
}

my $parser = $class->new;

$parser->output_string( \(my $output = '') );
my $pod = <<'END_POD';
  =head1 NAME

  Pod::Document - With an abstract

  =head1 SYNOPSIS

    welp();

  =head1 METHODS

  =head2 $self->some_method( \%options );

  =head2 options ( $options )

  =head1 options

  There are options.

  =cut
END_POD
$pod =~ s/^  //mg;
$parser->parse_string_document($pod);

like $output, qr/Pod::Document/;
like $output, qr/<a id="self--some_method---options">/;
like $output, qr/<a id="options"><\/a><a id="options----options">/;

done_testing;
