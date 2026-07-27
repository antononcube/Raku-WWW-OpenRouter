use v6.d;

use WWW::OpenRouter;
use Test;

my $model = 'openrouter/free';
my $method = 'tiny';

plan *;

unless %*ENV<OPENROUTER_API_KEY>:exists {
    skip 'OPENROUTER_API_KEY is not set', 1;
    done-testing;
    exit;
}

## 1
ok openrouter-playground(path => 'models', :$method, :$model);

## 2
ok openrouter-playground('What is the most important word in English today?', :$method, :$model);

## 3
ok openrouter-playground('Generate Raku code for a loop over a list', path => 'completions', model => Whatever, :$method);

## 4
ok openrouter-playground('Generate Raku code for a loop over a list', path => 'chat/completions', :$model, :$method);

done-testing;
