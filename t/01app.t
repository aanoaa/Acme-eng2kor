#!/usr/bin/env perl
use strict;
use warnings;
#use Test::More tests => 4;
use Test::More qw/no_plan/;

use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Request::Common;
use HTTP::Response;
use REST::Google::Translate;
use utf8;
binmode(STDOUT, ":utf8");

diag <<EOF
********************************* WARNING *********************************
Daum API key 를 발급받아서 사용하기를 권장합니다.
발급방법은 아래를 참고하세요.
http://dna.daum.net/griffin/do/DevDocs/read?bbsId=DevDocs&articleId=11
EOF
if !$ENV{DAUM_ENDIC_KEY};

$ENV{DAUM_ENDIC_KEY} = 'DAUM_DIC_DEMO_APIKEY' if !$ENV{DAUM_ENDIC_KEY};

my $url = "http://apis.daum.net/dic/endic?apikey=43b0914a71fc49af62ad3ea6521d95400c308805&kind=WORD&output=json&q=some";
my $ua = LWP::UserAgent->new;
my $res = $ua->request(GET $url);

# daum api
ok( $res = $ua->request(GET $url), 'JSON 데이터 요청' );
ok( $res->is_success, '200 OK' );
TODO: {
	local $TODO = "json 으로 응답이 오긴했지만, 현재의 content-type은 text/plain";
	is( $res->content_type, 'application/json', 'JSON content type' );
}
like( $res->content, qr/some/, "요청한 단어를 포함" );

# google translate
BEGIN { use_ok( 'REST::Google::Translate' ); }
REST::Google::Translate->http_referer('http://localhost');
$res = REST::Google::Translate->new(
	q => "hello, world", 
	langpair => 'en|ko', 
);
my $translated = $res->responseData->translatedText;

is( $res->responseStatus, 200, 'google translate 200 OK');
like( $translated, qr/안녕하세요/, "요청한 문장을 번역" );
