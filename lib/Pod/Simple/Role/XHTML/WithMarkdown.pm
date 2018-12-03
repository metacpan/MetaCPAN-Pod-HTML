package Pod::Simple::Role::XHTML::WithMarkdown;
use HTML::Entities qw(encode_entities);
use Scalar::Util qw(weaken);
use URL::Encode qw(url_decode_utf8);
use Moo::Role;
use namespace::clean;

our $VERSION = '0.002001';
$VERSION =~ tr/_//d;

has __markdown_renderer => (is => 'lazy');
sub _build___markdown_renderer {
    my $self = shift;
    weaken $self;
    my $renderer = Text::Markdown::_WithLinkFilter->new;
    $renderer->__link_filter(sub {
        my $uri = shift;
        my ($pod) = /^urn:pod:(.*)/
            or return undef;

        $pod = url_decode_utf8($pod);

        my ($module, $section) = split m{/}, $pod, 2;

        undef $module
            if defined $module && !length $module;
        undef $section
            if defined $section && !length $section;

        my $link = $self->resolve_pod_page_link($module, $section);

        if (wantarray) {
            my $title = '';
            if (defined $section) {
                $title = qq{"$section"};
                if (defined $module) {
                    $title .= ' in ';
                }
            }
            if (defined $module) {
                $title .= $module;
            }
            return ($link, $title);
        }

        return $link;
    });
    return $renderer;
}

sub BUILD {}
after BUILD => sub {
    $_[0]->accept_targets_as_html('markdown');
};

after start_for => sub {
    my ( $self, $item ) = @_;
    if ( $item->{target_matching} eq 'markdown' ) {
        $self->{scratch} = '';
    }
};

before end_for => sub {
    my ( $self, $item ) = @_;
    if ( $self->{__region_targets}[-1] eq 'markdown' ) {
        my $md = $self->{scratch};

        $self->{scratch}
            = $self->__markdown_renderer->($md);
    }
};

{
    package #hide
        Text::Markdown::_WithLinkFilter;
    use HTML::Entities qw(encode_entities decode_entities);
    use Moo;
    use namespace::clean;
    extends 'Text::Markdown';
    has __link_filter => (is => 'rw', init_arg => undef);

    around [qw(_GenerateAnchor _EncodeEmailAddress)] => sub {
        my ($orig, $self) = (shift, shift);
        my $result = $self->$orig(@_);

        # i don't like regexing HTML but oh well, it's targetted
        my ($before, $url, $after) = $result =~ /\A(<a href=")([^"]+)(".*)\z/s;
        if ($url) {
            my $new_url = $self->__link_filter->(decode_entities($url));
            $url = encode_entities($new_url)
                if defined $new_url;

            return $before . $new_url . $after;
        }
        return $result;
    };

    around _DoAutoLinks => sub {
        my ($orig, $self) = (shift, shift);
        my $result = $self->$orig(@_);

        my ($before, $url, $after) = $result =~ /\A(<a href=")([^"]+)(".*\z)/s;
        if ($url) {
            my ($new_url, $new_label) = $self->__link_filter->(decode_entities($url));
            $url = encode_entities($new_url)
                if defined $new_url;

            $after = '">'.encode_entities($new_label).'</a>';

            return $before . $new_url . $after;
        }
        return $result;
    };
}
1;
__END__

=encoding UTF-8

=head1 NAME

Pod::Simple::Role::XHTML::WithMarkdown - Support rendering embedded Markdown

=head1 SYNOPSIS

  package MyPodParser;
  with 'Pod::Simple::Role::XHTML::WithMarkdown';

  my $parser = MyPodParser->new;
  $parser->output_string(\my $html);
  $parser->parse_string_document($pod);

=head1 DESCRIPTION

Supports Pod sections using Markdown.

=head1 SUPPORT

See L<MetaCPAN::Pod::XHTML> for support and contact information.

=head1 AUTHORS

See L<MetaCPAN::Pod::XHTML> for authors.

=head1 COPYRIGHT AND LICENSE

See L<MetaCPAN::Pod::XHTML> for the copyright and license.

=cut
