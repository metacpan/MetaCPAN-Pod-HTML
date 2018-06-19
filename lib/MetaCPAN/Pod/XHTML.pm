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
  Pod::Simple::Role::StripVerbatimIndent
);

1;
__END__

=head1 NAME

MetaCPAN::Pod::XHTML - Format Pod as HTML for MetaCPAN

=head1 SYNOPSIS

  my $parser = MetaCPAN::Pod::XHTML->new;
  $parser->link_mappings({
    'Pod::Simple::Subclassing' => '/pod/distribution/Pod-Simple/lib/Pod/Simple/Subclassing.pod',
  });
  $parser->output_string(\my $html);
  $parser->parse_string_document($pod);

=head1 DESCRIPTION

This is a subclass of Pod::Simple::XHTML with improved header linking, link
overrides, and errata included in the HTML.  Used internally by MetaCPAN.

=head1 ROLES

The behavior of this subclass is implemented through reusable roles:

=over 4

=item *

L<Pod::Simple::Role::XHTML::WithLinkMappings>

=item *

L<Pod::Simple::Role::XHTML::WithAccurateTargets>

=item *

L<Pod::Simple::Role::XHTML::WithErrata>

=item *

L<Pod::Simple::Role::StripVerbatimIndent>

=back

=head1 AUTHOR

haarg - Graham Knop (cpan:HAARG) <haarg@haarg.org>

=head1 CONTRIBUTORS

=over 4

=item *

Olaf Alders <olaf@wundersolutions.com>

=item *

Randy Stauner <randy@magnificent-tears.com>

=item *

Moritz Onken <onken@netcubed.de>

=item *

Grant McLean <grant@mclean.net.nz>

=back

=head1 COPYRIGHT

Copyright (c) 2017 the MetaCPAN::Pod::XHTML L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself. See L<http://dev.perl.org/licenses/>.

=cut
