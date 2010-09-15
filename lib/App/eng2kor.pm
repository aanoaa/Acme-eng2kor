package App::eng2kor;

our $VERSION = '1.012';
$VERSION = eval $VERSION;

use Any::Moose;
use Any::Moose '::Util::TypeConstraints';
use JSON qw/decode_json/;
use Const::Fast;
use Encode qw/decode/;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;
use namespace::autoclean;

const my $DAUM_ENDIC_URL =>
  "http://apis.daum.net/dic/endic?apikey=%s&kind=WORD&output=json&q=%s";
const my $DAUM_ENDIC_DEMO_KEY =>
  "DAUM_DIC_DEMO_APIKEY";
const my $GOOGLE_TRANSLATE_API_URL =>
  "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=%s&langpair=%s";

subtype 'LangTags' => as 'Str' =>
  where { m/[a-zA-Z\-]+/ };  # en, en-US, ja ...

has 'src' => ( is => 'rw', isa => 'LangTags', default => 'en' );
has 'dst' => ( is => 'rw', isa => 'LangTags', default => 'ko' );

sub translate {
    my ($self, $word) = @_;
	map { s/^\s+//; s/\s+$// } $word;
	die "wrong argument!\n" if length($word) == 0;
	if ($word =~ m{^\s*http://twitter.com/\w+/status/[0-9]+$}) {
		my $request  = HTTP::Request->new( GET => $word );
		my $ua       = LWP::UserAgent->new;
		my $response = $ua->request($request);
		die STDERR $response->status_line, "\n" unless $response->is_success;
		($word) = $response->content =~ m{<meta content="(.*?)" name="description" />};
		$word = decode('UTF-8', $word);
	}

	my @result;
	push @result, $self->get_google($word);
	push @result, $self->get_daum($word);
	return @result;
}

sub get_google {
    my ($self, $word) = @_;
    my $url = $self->url_encode(
        sprintf( $GOOGLE_TRANSLATE_API_URL, $word, $self->{src} . '|' . $self->{dst} ) );
    my $json = $self->translated_to_json($url);
    return {
        origin     => $word,
        translated => $json->{responseData}->{translatedText}
    };
}

sub get_daum {
    my ($self, $word) = @_;
    $ENV{DAUM_ENDIC_KEY} = $DAUM_ENDIC_DEMO_KEY unless $ENV{DAUM_ENDIC_KEY};
    my $url = $self->url_encode(
        sprintf( $DAUM_ENDIC_URL, $ENV{DAUM_ENDIC_KEY}, $word ) );
    my $json = $self->translated_to_json($url);
    my @translated;
    for my $item ( @{ $json->{channel}->{item} } ) {
        push @translated,
          { origin => $item->{title}, translated => $item->{description} };
    }

    return @translated;
}

sub translated_to_json {
    my ($self, $url) = @_;
    my $request  = HTTP::Request->new( GET => $url );
    my $ua       = LWP::UserAgent->new;
    my $response = $ua->request($request);
    die STDERR $response->status_line, "\n" unless $response->is_success;
    return decode_json( $response->content );
}

sub url_encode {
    my ($self, $url) = @_;
    $url =~ s/([^A-Za-z0-9:\/?&]=)/sprintf("%%%02X", ord($1))/seg;
    return $url;
}

sub url_decode {
    my ($self, $url) = @_;
    $url =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    return $url;
}

__PACKAGE__->meta->make_immutable;



=pod

=head1 NAME

App::eng2kor

=head1 VERSION

version 1.010

=head1 SYNOPSIS

	use App::eng2kor;
	my $app = new App::eng2kor;
	binmode STDOUT, ':encoding(UTF-8)';
	my @result = $app->translate('some');
	for my $item (@result) {
		print $item->{origin}, "\n";
		print "\t$item->{translated}\n";
	}

=head1 SEE ALSO

* L<http://dna.daum.net/griffin/do/DevDocs/read?bbsId=DevDocs&articleId=11>

* L<http://code.google.com/intl/en/apis/ajaxlanguage/>

=cut


__END__


1;
