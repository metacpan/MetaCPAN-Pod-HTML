package Pod::Simple::Role::XHTML::RepairLinkEncoding;
use HTML::Entities qw(decode_entities encode_entities);
use URL::Encode qw(url_encode_utf8);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.002001';
$VERSION =~ tr/_//d;

around resolve_pod_page_link => sub {
  my $orig = shift;
  my $self = shift;
  local $self->{__resolving_link} = 1;
  $self->$orig(@_);
};

around end_item_text => sub {
  my $orig = shift;
  my $self = shift;
  local $self->{__in_end_item_text} = 1;
  $self->$orig(@_);
};

around _end_head => sub {
  my $orig = shift;
  my $self = shift;
  local $self->{__in_end_head} = 1;
  $self->$orig(@_);
  my $index_entry = $self->{'to_index'}[-1];

  # the index entry added by default has the id of the link target, and uses
  # it directly as a URL fragment. we need to re-encode it to a proper form.
  $index_entry->[1] = encode_entities(
    url_encode_utf8( decode_entities( $index_entry->[1] ) ) );
};

around idify => sub {
  my $orig = shift;
  my $self = shift;
  my ($text, $not_unique) = @_;

  $text = decode_entities($text)
    if $self->{__in_end_item_text} || $self->{__in_end_head};
  $text =~ s/<[^>]+>//g
    if $self->{__in_end_item_text};

  my $id = $self->$orig($text, $not_unique);

  $id = url_encode_utf8($id)
    if $self->{__resolving_link};

  $id = encode_entities($id);
  return $id;
};

1;
__END__

=head1 NAME

Pod::Simple::Role::XHTML::WithAccurateTargets - Use more accurate link targets

=head1 SYNOPSIS

  package MyPodParser;
  with 'Pod::Simple::Role::XHTML::WithAccurateTargets';

  my $parser = MyPodParser->new;
  $parser->output_string(\my $html);
  $parser->parse_string_document($pod);

=head1 DESCRIPTION

The normal targets used by L<Pod::Simple::XHTML> are heavily filtered, meaning
heading that are primarily symbolic (such as C<@_> in L<perlvar>) can't be
usefully linked externally.  Link targets will be added using minimal filtering,
which will also be used for linking to external pages.

=head1 SUPPORT

See L<MetaCPAN::Pod::XHTML> for support and contact information.

=head1 AUTHORS

See L<MetaCPAN::Pod::XHTML> for authors.

=head1 COPYRIGHT AND LICENSE

See L<MetaCPAN::Pod::XHTML> for the copyright and license.

=cut

