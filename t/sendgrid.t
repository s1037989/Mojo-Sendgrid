use Test::More;
use Test::Mojo;
use Mojolicious::Lite;
use Mojo::Sendgrid;

$ENV{SENDGRID_APIURL} = '/dummy';

my $t = Test::Mojo->new;
my $sendgrid = Mojo::Sendgrid->new(config => {apikey => 'kjwhef'});
my $res;

post '/dummy' => sub {shift->render(json => {message => 'success'}) };

$sendgrid->once(mail_send => sub {
  my ($sendgrid, $ua, $tx) = @_;
  $res = $tx->res->json;
  Mojo::IOLoop->stop;
});

$sendgrid->mail(
  to=>q(x@y.com),
  from=>q(x@y.com),
  subject=>time,
  text=>time
)->send;

Mojo::IOLoop->start;

isa_ok $sendgrid, 'Mojo::Sendgrid';
is_deeply $res, {message => 'success'}, 'correct response, nb';

is_deeply
  $sendgrid->mail(
    to=>q(x@y.com),
    from=>q(x@y.com),
    subject=>time,
    text=>time
  )->send->res->json,
  {message => 'success'},
  'correct response, b';

my $e = eval { $sendgrid->mail->send->res->json };
ok $@, 'exception expected';

done_testing;
