use strict;
use warnings;
use Test::More;

my $class;
{
  package ParserWithStrippedIndents;
  $class = __PACKAGE__;
  use Moo;
  extends 'Pod::Simple::XHTML';
  with 'Pod::Simple::Role::StripVerbatimIndent';
}

sub parse {
  my ($pod, $cb) = @_;

  my $parser = $class->new;
  $cb->($parser)
    if $cb;
  $parser->output_string( \(my $output = '') );
  $parser->parse_string_document("=pod\n\n$pod");

  my ($pre_text) = $output =~ m{<pre><code>(.*?)</code></pre>}s;
  $pre_text =~ s/\n?\z/\n/;

  return $pre_text;
}

is parse(<<'END_POD'), <<'END_TEXT';
    Foo
      Bar

    Guff
END_POD
Foo
  Bar

Guff
END_TEXT

is parse(<<'END_POD', sub { $_[0]->strip_verbatim_indent(sub { undef } ) } ), <<'END_TEXT';
    Foo
      Bar

    Guff
END_POD
    Foo
      Bar

    Guff
END_TEXT


is parse(<<'END_POD'), <<'END_TEXT';
    Foo
    Bar	Bar
    Guff	Guff
END_POD
Foo
Bar	Bar
Guff	Guff
END_TEXT

is parse(<<'END_POD'), <<'END_TEXT';
	Foo
		Bar
		Guff
END_POD
Foo
	Bar
	Guff
END_TEXT

is parse(<<'END_POD'), <<'END_TEXT';
    Foo
	Bar
	Guff
END_POD
Foo
    Bar
    Guff
END_TEXT

done_testing;
