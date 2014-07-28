requires 'perl', 'v5.10.1';

on test => sub {
    requires 'Test::More', '0.88';
    requires 'Test::Exception', '0.32';
    requires 'Test::RequiresInternet', '0.02';
};

requires 'Catmandu', '>=0.8014';
requires 'Moo', '>=1.004';
requires 'Furl', '0.41';
requires 'Catmandu::XML', '0.14';
