package Pod::Simple::Role::XHTML::WithAccurateTargets;
use HTML::Entities qw(decode_entities encode_entities);
use URL::Encode qw(url_encode_utf8);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.001002';
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

around _end_head => sub {
  my $orig = shift;
  my $self = shift;
  my $head_name = $self->{htext};
  $self->{more_ids} = [ $self->id_extras($head_name) ];
  $self->$orig(@_);
  my $index_entry = $self->{'to_index'}[-1];
  $index_entry->[1] = encode_entities(
    url_encode_utf8( decode_entities( $index_entry->[1] ) ) );
  return;
};

around end_item_text => sub {
  my $orig = shift;
  my $self = shift;
  if ( $self->{anchor_items} ) {
    my $item_name = $self->{'scratch'};
    $self->{more_ids} = [ $self->id_extras($item_name) ];
  }
  $self->$orig(@_);
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
