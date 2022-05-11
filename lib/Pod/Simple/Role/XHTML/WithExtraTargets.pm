package Pod::Simple::Role::XHTML::WithExtraTargets;
use HTML::Entities qw(decode_entities encode_entities);
use URL::Encode qw(url_encode_utf8);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.002001';
$VERSION =~ tr/_//d;

with qw(Pod::Simple::Role::XHTML::WithPostProcess);

before _end_head => sub {
  my $self = shift;
  my $head_name = $self->{htext};
  $self->{__more_ids_for} = $head_name;
};

before end_item_text => sub {
  my $self = shift;
  if ( $self->{anchor_items} ) {
    my $item_name = $self->{'scratch'};
    $self->{__more_ids_for} = $item_name;
  }
};

after pre_process => sub {
  my ($self, $content) = @_;
  if (my $for = delete $self->{__more_ids_for}) {
    # match the first tag in the content being added. this will contain the
    # primary id to use for links, so it should be unique. we'll be searching
    # for it later to add the additional link targets.
    $content =~ /(<\w[^>]*>)/s;
    $self->{__extra_ids}{$1} = $for;
  }
};

around post_process => sub {
  my $orig = shift;
  my $self = shift;
  my $output = $self->$orig(@_);
  my $extras = delete $self->{__extra_ids}
    or return $output;

  # search for any of the tags we found when preprocessing
  my $match = join '|', map quotemeta, keys %$extras;
  # inject extra links for each tag found
  $output =~ s{($match)}{
    join '', $1, map qq{<a id="$_"></a>}, $self->id_extras($extras->{$1})
  }ge;
  return $output;
};

sub id_extras {
  my ( $self, $t ) = @_;

  $t =~ s/<[^>]+>//g;
  $t = decode_entities($t);
  $t =~ s/^\s+//;
  $t =~ s/\s+$//;
  $t =~ s/[\s-]+/-/g;

  # $full will be our preferred linking style, without much filtering
  # $first will be the first word, often a method/function name
  # $old will be a heavily filtered form for backwards compatibility

  my $full = $t;
  my ($first) = $t =~ /^(\w+)/;
  $t =~ s/^[^a-zA-Z]+//;
  $t =~ s/^$/pod/;
  $t =~ s/[^-a-zA-Z0-9_:.]+/-/g;
  $t =~ s/[-:.]+$//;
  my $old = $t;
  my %s   = ( $full => 1 );
  my $ids = $self->{ids};
  return
    map encode_entities($_),
    map {
      my $i = '';
      $i++ while $ids->{"$_$i"}++;
      "$_$i";
    }
    grep !$s{$_}++,
    grep defined,
    ( $first, $old );
}


1;
__END__

=head1 NAME

Pod::Simple::Role::XHTML::WithExtraTargets - Add additional useful link targets

=head1 SYNOPSIS

  package MyPodParser;
  with 'Pod::Simple::Role::XHTML::WithAccurateTargets';

  my $parser = MyPodParser->new;
  $parser->output_string(\my $html);
  $parser->parse_string_document($pod);

=head1 DESCRIPTION

Adds multiple link targets to rendered headings to allow more useful linking.

Many headings for functions and methods include the function signature.  This
makes linking to the headings awkward.  Link targets based on the first word
of headings will be added to make linking easier.  This form of linking is
very common when linking to sections of L<perlfunc>, allowing links like
C<< LE<lt>perlfunc/openE<gt> >>.

Also adds link targets compatible with standard L<Pod::Simple::XHTML>.

=head1 SUPPORT

See L<MetaCPAN::Pod::XHTML> for support and contact information.

=head1 AUTHORS

See L<MetaCPAN::Pod::XHTML> for authors.

=head1 COPYRIGHT AND LICENSE

See L<MetaCPAN::Pod::XHTML> for the copyright and license.

=cut
