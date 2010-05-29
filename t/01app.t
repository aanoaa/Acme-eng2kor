#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 8;

use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Request::Common;
use HTTP::Response;
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
	local $TODO = "json 으로 응답이 오긴했지만, 현재의 content-type은 application/json 이 아님";
	is( $res->content_type, 'application/json', 'JSON content type' );
}
like( $res->content, qr/some/, "요청한 단어를 포함" );


# google api
$url = 'http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=some&langpair=en|ko', 
ok( $res = $ua->request(GET $url), 'JSON 데이터 요청' );
ok( $res->is_success, '200 OK' );
TODO: {
	local $TODO = "json 으로 응답이 오긴했지만, 현재의 content-type은 application/json 이 아님";
	is( $res->content_type, 'application/json', 'JSON content type' );
}
like( $res->content, qr/responseData/, "응답성공" );
