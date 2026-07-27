use v6.d;

use WWW::OpenRouter;
use Test;

my $method = 'tiny';
my $model = 'openrouter/free';

plan *;

unless %*ENV<OPENROUTER_API_KEY>:exists {
    skip 'OPENROUTER_API_KEY is not set', 1;
    done-testing;
    exit;
}

## 1
ok openrouter-completion('Generate Raku code for a loop over a list', :$model, :$method);

## 2
ok openrouter-completion('Generate Raku code for a loop over a list', :$model, :$method, format => 'values');

## 3
ok openrouter-completion('Generate Raku code for a loop over a list', :$model, :$method);

## 4
ok openrouter-completion('Generate Raku code for a loop over a list', model => $model, :$method, stream => False);

## 5
dies-ok {
    openrouter-completion('Generate Raku code for a loop over a list', model => 'mistral-blah-blah', :$method)
};


done-testing;
