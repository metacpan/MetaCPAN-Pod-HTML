package Pod::Simple::Role::XHTML::WithErrata;
use HTML::Entities qw(encode_entities);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.001002';
$VERSION =~ tr/_//d;

around _gen_errata => sub {
  return;    # override the default errata formatting
};

around end_Document => sub {
  my $orig = shift;
  my $self = shift;
  $self->_emit_custom_errata
    if $self->{errata};
  $self->$orig(@_);
};

sub _emit_custom_errata {
  my $self = shift;

  my $tag = sub {
    my $name       = shift;
    my $attributes = '';
    if ( ref( $_[0] ) ) {
      my $attr = shift;
      while ( my ( $k, $v ) = each %$attr ) {
        $attributes .= qq{ $k="} . encode_entities($v) . '"';
      }
    }
    my @body = map { /^</ ? $_ : encode_entities($_) } @_;
    return join( '', "<$name$attributes>", @body, "</$name>" );
  };

  my @errors = map {
    my $line  = $_;
    my $error = $self->{'errata'}->{$line};
    (
      $tag->( 'dt', "Around line $line:" ),
      $tag->( 'dd', map { $tag->( 'p', $_ ) } @$error ),
    );
  } sort { $a <=> $b } keys %{ $self->{'errata'} };

  my $error_count = keys %{ $self->{'errata'} };
  my $s = $error_count == 1 ? '' : 's';

  $self->{'scratch'} = $tag->(
    'div',
    { class => "pod-errors" },
    $tag->( 'p', "$error_count POD Error$s" ),
    $tag->(
      'div',
      { class => "pod-errors-detail" },
      $tag->(
        'p',
        'The following errors were encountered while parsing the POD:'
      ),
      $tag->( 'dl', @errors ),
    ),
  );
  $self->emit;
}

1;
__END__
