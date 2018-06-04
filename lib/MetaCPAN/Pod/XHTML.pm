package MetaCPAN::Pod::XHTML;
use HTML::Entities qw(decode_entities);
use Moo;
use namespace::clean;

our $VERSION = '0.001002';
$VERSION =~ tr/_//d;

extends 'Pod::Simple::XHTML';
with qw(
  Pod::Simple::Role::XHTML::WithLinkMappings
  Pod::Simple::Role::XHTML::WithAccurateTargets
  Pod::Simple::Role::XHTML::WithErrata
);

1;

=pod

=head1 NAME

MetaCPAN::Pod::XHTML - Format Pod as HTML for MetaCPAN

=head1 ATTRIBUTES

=head2 link_mappings

=cut
