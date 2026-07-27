use v6.d;

use WWW::OpenRouter;
use Test;

my $method = 'tiny';

plan *;

unless %*ENV<OPENROUTER_API_KEY>:exists {
    skip 'OPENROUTER_API_KEY is not set', 1;
    done-testing;
    exit;
}

## 1
my $query = 'make a classifier with the method RandomForeset over the data dfTitanic; show precision and accuracy; plot True Positive Rate vs Positive Predictive Value.';

is openrouter-embeddings($query, format => "values", :$method).WHAT ∈ (Array, Positional, Seq), True;

## 2
my @queries = [
        'make a classifier with the method RandomForeset over the data dfTitanic',
        'show precision and accuracy',
        'plot True Positive Rate vs Positive Predictive Value',
        'what is a good meat and potatoes recipe'
];

is openrouter-embeddings(@queries, format => "values", :$method, encoding-format => 'base64').WHAT ∈ (Array, Positional, Seq), True;

## 3
is openrouter-embeddings(@queries, format => "values", :$method).elems, @queries.elems;

done-testing;
