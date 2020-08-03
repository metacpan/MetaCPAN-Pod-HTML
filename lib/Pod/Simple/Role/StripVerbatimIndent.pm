package Pod::Simple::Role::StripVerbatimIndent;
use Moo::Role;
use namespace::clean;

sub BUILD {}
after BUILD => sub {
  my $self = shift;
  $self->expand_verbatim_tabs(0);
};

my $tab_width = 8;
my $expand = sub {
  my ($string, $max) = @_;
  $max = length $string
    if !defined $max;
  $max--;
  while (
    $string =~ s/^( {0,$max})(\t)/$1 . (" " x ( ( $tab_width ) - ( length($1) % $tab_width ) ) )/e
  ) {}
  return $string;
};

around strip_verbatim_indent => sub {
  my ($orig, $self) = (shift, shift);
  if (my $strip = $self->$orig(@_)) {
    return $strip;
  }
  return sub {
    my ($para) = @_;
    my ($min_indent) =
      sort { $a <=> $b }
      map length($expand->($_)),
      map /^([ \t]+)/m,
      @$para;

    my $strip_indent = ' ' x $min_indent;

    $_ = $expand->($_, $min_indent) and s/\A\Q$strip_indent//
      for @$para;

    return;
  }
};

1;

=encoding UTF-8

=head1 NAME

Pod::Simple::Role::StripVerbatimIndent - Strip indentation from verbatim sections sanely

=head1 SYNOPSIS

  package MyPodParser;
  with 'Pod::Simple::Role::StripVerbatimIndent;

  my $parser = MyPodParser->new;
  $parser->output_string(\my $html);
  $parser->parse_string_document($pod);

=head1 DESCRIPTION

Strips the indentation from verbatim blocks, while not corrupting tab indents.

The shortest indentation in the verbatim block (excluding empty lines) will be
stripped from all lines.

=head1 SUPPORT

See L<MetaCPAN::Pod::XHTML> for support and contact information.

=head1 AUTHORS

See L<MetaCPAN::Pod::XHTML> for authors.

=head1 COPYRIGHT AND LICENSE

See L<MetaCPAN::Pod::XHTML> for the copyright and license.

=cut
