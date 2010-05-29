package App::eng2kor;

use strict;
use warnings;
use 5.8.0;
use utf8;
use JSON;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;
use File::Slurp qw/slurp/;
use Term::ANSIColor qw/:constants/;
use constant {
	DAUM_ENDIC_URL => "http://apis.daum.net/dic/endic?apikey=%s&kind=WORD&output=json&q=%s", 
	GOOGLE_TRANSLATE_API_URL => 'http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=%s&langpair=%s', 
};

binmode STDOUT, 'utf8';

our $VERSION = '1.0001';
$VERSION = eval $VERSION;

sub run_command {
    my ( undef, $opt, @args ) = @_;
    my $self = bless $opt, __PACKAGE__;
    $self->run_command_exec(@args);
}

sub run_command_exec {
    my($self, @words) = @_;
	local $Term::ANSIColor::AUTORESET = 1;
	for my $word (@words) {
		my $trim_word = $word;
		$trim_word =~ s/\s+//g;
		next unless length $trim_word;

		print BOLD BLUE $word, "\n";

		my $translated;
		$translated = get_google($word, $self->{lang});
		while (my ($key, $value) = each %{ $translated }) {
			print "$key\n";
			print "\t$value\n";
		}

		$translated = get_daum($word);
		while (my ($key, $value) = each %{ $translated }) {
			print "$key\n";
			print "\t$value\n";
		}
	}
}

sub get_google {
	my ($origin, $lang) = @_;
	my $url = url_encode(sprintf(GOOGLE_TRANSLATE_API_URL, $origin, $lang));
	my $translated = get_translated($url, $lang);
	return { $origin => $translated->{responseData}->{translatedText} };
}

sub get_daum {
    my ($origin, $lang) = @_;
	$ENV{DAUM_ENDIC_KEY} = 'DAUM_DIC_DEMO_APIKEY' unless $ENV{DAUM_ENDIC_KEY};
	my $url = url_encode(sprintf(DAUM_ENDIC_URL, $ENV{DAUM_ENDIC_KEY}, $origin));
	my $translated = get_translated($url, $lang);
	my %translated;
	for my $translated_item (@{ $translated->{channel}->{item} }) {
		$translated{ $translated_item->{title} } = $translated_item->{description};
	}

	return \%translated;
}

sub get_translated {
	my ($url, $lang) = @_;
	my $request = HTTP::Request->new(GET => $url);
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request($request);
	print STDERR $response->status_line, "\n" unless $response->is_success;
	#return from_json($response->content, utf8 => 1);
	return decode_json($response->content);
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

__END__

=head1 SYNOPSIS

	eng2kor --help

	eng2kor "english"                                                   # eng2kor
	eng2kor some thing "something"                                      # multiple
	eng2kor "this is sentence"                                          # sentence
	eng2kor --lang='ko|en' 한쿡말                                       # kor2eng
	eng2kor --file=eng.txt                                              # file
	echo "word" | eng2kor                                               # pipe input
	export DAUM_ENDIC_KEY=e4208a9e48744c40f2b7459162062313ed9878f6      # note: just sample, invalid key

=head1 INSTALL

	perl Makefile.PL
	make
	make test
	make install

=head1 SEE ALSO

* L<http://dna.daum.net/griffin/do/DevDocs/read?bbsId=DevDocs&articleId=11>

* L<http://code.google.com/intl/en/apis/ajaxlanguage/>

=cut

1;
