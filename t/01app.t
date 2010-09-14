#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
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
ok( $app = App::eng2kor->new(word => 'some'), 'new');
is( $app->word, 'some', 'origin word');
my @result;
ok( @result = $app->translate, 'HTTP REQ/RES' );
is( $result[0]->{origin}, 'some', 'origin word - 2' );
ok( $result[0]->{translated}, 'translated' );
ok( $app->word('foo'), 'change word' );
ok( @result = $app->translate, 'HTTP REQ/RES - 2' );
