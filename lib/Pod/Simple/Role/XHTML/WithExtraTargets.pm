package Pod::Simple::Role::XHTML::WithExtraTargets;
use HTML::Entities qw(decode_entities encode_entities);
use URL::Encode qw(url_encode_utf8);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.002001';
$VERSION =~ tr/_//d;

before _end_head => sub {
  my $self = shift;
  my $head_name = $self->{htext};
  $self->{more_ids} = [ $self->id_extras($head_name) ];
};

before end_item_text => sub {
  my $self = shift;
  if ( $self->{anchor_items} ) {
    my $item_name = $self->{'scratch'};
    $self->{more_ids} = [ $self->id_extras($item_name) ];
  }
};

around emit => sub {
  my $orig = shift;
  my $self = shift;
  my $ids  = delete $self->{more_ids};
  if ( $ids && @$ids ) {
    my $scratch = $self->{scratch};
    my $add = join '', map qq{<a id="$_"></a>}, @$ids;
    $scratch =~ s/(<\w[^>]*>)/$1$add/;
    $self->{scratch} = $scratch;
  }
  $self->$orig(@_);
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
