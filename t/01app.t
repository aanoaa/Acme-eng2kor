#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 9;
use App::eng2kor;
use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Request::Common;
use HTTP::Response;
use utf8;
binmode( STDOUT, ":utf8" );

diag <<DESC
********************************* WARNING *********************************
Daum API key 를 발급받아서 사용하기를 권장합니다.
발급방법은 아래를 참고하세요.
http://dna.daum.net/griffin/do/DevDocs/read?bbsId=DevDocs&articleId=11
DESC
  if !$ENV{DAUM_ENDIC_KEY};

$ENV{DAUM_ENDIC_KEY} = 'DAUM_DIC_DEMO_APIKEY' if !$ENV{DAUM_ENDIC_KEY};
my $app;
my @result;
ok( $app = App::eng2kor->new, 'create new instance');
is( $app->src, 'en', 'src default');
is( $app->dst, 'ko', 'dst default');
ok( @result = $app->translate('some'), 'HTTP REQ/RES' );
ok( $app->src('ko'), 'change src');
ok( $app->dst('ja'), 'change dst');
is( $app->src, 'ko', 'src changed corrently');
is( $app->dst, 'ja', 'dst changed corrently');
ok( @result = $app->translate('안녕하세요'), 'HTTP REQ/RES' );
