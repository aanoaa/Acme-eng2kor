#!/usr/bin/env perl
use strict;
use warnings;
use Test::More qw/no_plan/;

use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Request::Common;
use HTTP::Response;

diag <<EOF
********************************* WARNING *********************************
Daum API key 가 있어야 합니다. api 키를 발급받아야지만 사용 가능합니다.
발급방법은 아래를 참고하세요.
http://dna.daum.net/griffin/do/DevDocs/read?bbsId=DevDocs&articleId=11
EOF
if !$ENV{DAUM_ENDIC_KEY};

SKIP: {
	skip "API 키가 없으면 테스트 할 수 없습니다.", 1 if !$ENV{DAUM_ENDIC_KEY};
	my $url = "http://apis.daum.net/dic/endic?apikey=43b0914a71fc49af62ad3ea6521d95400c308805&kind=WORD&output=json&q=some";
	my $ua = LWP::UserAgent->new;
	my $res = $ua->request(GET $url);

	ok( $res = $ua->request(GET $url), 'JSON 데이터 요청' );
	ok( $res->is_success, '200 OK' );
	TODO: {
		local $TODO = "json 으로 응답이 오긴했지만, 현재의 content-type은 text/plain";
		is( $res->content_type, 'application/json', 'JSON content type' );
	}
	like( $res->content, qr/some/, "요청한 단어를 포함" );
}
