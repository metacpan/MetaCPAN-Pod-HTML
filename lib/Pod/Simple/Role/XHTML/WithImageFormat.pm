package Pod::Simple::Role::XHTML::WithImageFormat;
use HTML::Entities qw(encode_entities);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.001002';
$VERSION =~ tr/_//d;

sub BUILD {}
after BUILD => sub {
    $_[0]->accept_targets_as_html('image');
};

after start_for => sub {
    my ( $self, $item ) = @_;
    if ( $item->{target_matching} eq 'image' ) {
        $self->{scratch} = '';
    }
};

before end_for => sub {
    my ( $self, $item ) = @_;
    if ( $self->{__region_targets}[-1] eq 'image' ) {
        my $img = $self->{scratch};
        s/\A\s+//, s/\s+\z// for $img;
        $self->{scratch}
            = '<img src="' . encode_entities($img) . '" />';
    }
};

1;
__END__

=encoding UTF-8

=head1 NAME

Pod::Simple::Role::XHTML::WithImageFormat - Support C<=for image>

=head1 SYNOPSIS

  package MyPodParser;
  with 'Pod::Simple::Role::XHTML::WithImageFormat';

  my $parser = MyPodParser->new;
  $parser->output_string(\my $html);
  $parser->parse_string_document($pod);

=head1 DESCRIPTION

Supports an image format in C<=for> or C<=begin>/C<=end> directives, accepting
a simple URL and formatting it as an C<< <img> >> tag.

=head1 SUPPORT

See L<MetaCPAN::Pod::XHTML> for support and contact information.

=head1 AUTHORS

See L<MetaCPAN::Pod::XHTML> for authors.

=head1 COPYRIGHT AND LICENSE

See L<MetaCPAN::Pod::XHTML> for the copyright and license.

=cut
