package Pod::Simple::Role::XHTML::WithAccurateTargets;
use HTML::Entities qw(decode_entities encode_entities);
use URL::Encode qw(url_encode_utf8);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.002001';
$VERSION =~ tr/_//d;

sub resolve_pod_page_link {
    my ( $self, $module, $section ) = @_;
    return undef
        unless defined $module || defined $section;
    $section = defined $section ? '#' . $self->idify( $section, 1 ) : '';
    return $section
        unless defined $module;
    my ( $prefix, $postfix ) = map +( defined $_ ? $_ : '' ),
        $self->perldoc_url_prefix, $self->perldoc_url_postfix;
    return $prefix . $module . $postfix . $section;
}

after _end_head => sub {
  my $self = shift;
  # the index entry added by default has the id of the link target, and uses
  # it directly as a URL fragment. we need to re-encode it to a proper form.
  my $index_entry = $self->{'to_index'}[-1];
  $index_entry->[1] = encode_entities(
    url_encode_utf8( decode_entities( $index_entry->[1] ) ) );
};

sub idify {
  my ( $self, $t, $for_link ) = @_;

  $t =~ s/<[^>]+>//g;
  $t = decode_entities($t);
  $t =~ s/^\s+//;
  $t =~ s/\s+$//;
  $t =~ s/[\s-]+/-/g;

  return url_encode_utf8($t)
    if $for_link;

  my $ids = $self->{ids};
  my $i   = '';
  $i++ while $ids->{"$t$i"}++;
  encode_entities("$t$i");
}

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
