package Pod::Simple::Role::XHTML::WithLinkMappings;
use HTML::Entities qw(decode_entities encode_entities);
use URL::Encode qw(url_encode_utf8);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.001002';
$VERSION =~ tr/_//d;

has link_mappings => ( is => 'rw' );

around resolve_pod_page_link => sub {
  my $orig = shift;
  my $self = shift;
  my $module = shift;
  if (defined $module) {
    my $link_map = $self->link_mappings || {};
    my $link = $link_map->{$module};
    $module = $link
      if defined $link;
  }
  $self->$orig($module, @_);
};

1;
__END__
