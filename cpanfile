requires 'perl', 'v5.10.1';

on test => sub {
    requires 'Test::More', '0.88';
    requires 'Test::Exception', '0.32';
};

requires 'Catmandu', '0.8002';
requires 'Moo', '>=1.004';
requires 'Furl', '0.41';
requires 'XML::Simple', '>= 2.2';
