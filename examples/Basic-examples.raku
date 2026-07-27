#!/usr/bin/env raku
use v6.d;

use WWW::OpenRouter;

#say openrouter-playground("What is the min speed of a rocket leaving Earh?", format => Whatever, max-tokens => 900);

#say openrouter-playground("What is the min speed of a rocket leaving Earh?", format => Whatever, max-tokens => 900);

say '=' x 120;

my @models = |openrouter-playground(path => 'models');

*<id>.say for @models;

say '-' x 120;

say openrouter-playground(path => 'models', format => 'values');

say '=' x 120;

#say mistralai-embeddings('hello world'.words);