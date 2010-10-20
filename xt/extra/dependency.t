use Test::Dependencies
    exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic DBIx::Simple::DataSection/],
    style   => 'light';
ok_dependencies();
