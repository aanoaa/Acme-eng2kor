package App::eng2kor;

our $VERSION = '1.010';
$VERSION = eval $VERSION;

use Any::Moose;
use Any::Moose '::Util::TypeConstraints';
use JSON;
use Const::Fast;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;
use File::Slurp qw/slurp/;
use namespace::autoclean;

const my $DAUM_ENDIC_URL =>
  "http://apis.daum.net/dic/endic?apikey=%s&kind=WORD&output=json&q=%s";
const my $GOOGLE_TRANSLATE_API_URL =>
"http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=%s&langpair=%s";

has 'word' => ( is => 'rw', isa => 'Str', default => '' );

subtype 'FromTo' => as 'Str' =>
  where { m/[a-z]{2}|[a-z]{2}/ };  # ko|en, en|ko, ... # 영어 이외엔 안됨

has 'fromto' => ( is => 'ro', isa => 'FromTo', default => 'en|ko' );

sub translate {
    my ($self) = @_;
    map { s/^\s+//g; s/\s+$//g } $self->{word};
    die "wrong arguemnt\n" unless length $self->{word};

    #print "\e[7m$word\e[m\n";
    my $google = $self->get_google;
    my @daum   = $self->get_daum;
    unshift @daum, $google;
    return @daum;
}

sub get_google {
    my ($self) = @_;
    my $url = url_encode(
        sprintf( $GOOGLE_TRANSLATE_API_URL, $self->{word}, $self->{fromto} ) );
    my $translated = get_translated($url);
    return {
        origin     => $self->{word},
        translated => $translated->{responseData}->{translatedText}
    };
}

sub get_daum {
    my ($self) = @_;
    $ENV{DAUM_ENDIC_KEY} = 'DAUM_DIC_DEMO_APIKEY' unless $ENV{DAUM_ENDIC_KEY};
    my $url = url_encode(
        sprintf( $DAUM_ENDIC_URL, $ENV{DAUM_ENDIC_KEY}, $self->{word} ) );
    my $translated = get_translated($url);
    my @translated;
    for my $item ( @{ $translated->{channel}->{item} } ) {
        push @translated,
          { origin => $item->{title}, translated => $item->{description} };
    }

    return @translated;
}

sub get_translated {
    my ($url) = @_;
    my $request  = HTTP::Request->new( GET => $url );
    my $ua       = LWP::UserAgent->new;
    my $response = $ua->request($request);
    die STDERR $response->status_line, "\n" unless $response->is_success;
    return decode_json( $response->content );
}

sub url_encode {
    my $url = shift;
    $url =~ s/([^A-Za-z0-9:\/?&]=)/sprintf("%%%02X", ord($1))/seg;
    return $url;
}

sub url_decode {
    my $url = shift;
    $url =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    return $url;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 SYNOPSIS

	my $app = new App::eng2kor(word => 'some');
	binmode STDOUT, ':encoding(UTF-8)';
	my @result = $app->translate;
	for my $item (@result) {
		print $item->{origin}, "\n";
		print "\t$item->{translated}\n";
	}

=head1 SEE ALSO

* L<http://dna.daum.net/griffin/do/DevDocs/read?bbsId=DevDocs&articleId=11>

* L<http://code.google.com/intl/en/apis/ajaxlanguage/>

=cut

1;
