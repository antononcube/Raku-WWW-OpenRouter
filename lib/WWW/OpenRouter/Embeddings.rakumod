
unit module WWW::OpenRouter::Embeddings;

use WWW::OpenRouter::Models;
use WWW::OpenRouter::Request;
use JSON::Fast;

#============================================================
# Embeddings
#============================================================

#| OpenRouter embeddings.
our proto OpenRouterEmbeddings($prompt,
                              :$model = Whatever,
                              :$encoding-format = Whatever,
                              :api-key(:$auth-key) is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'tiny',
                              Str :$base-url = 'https://openrouter.ai/api/v1'
                              ) is export {*}


#| OpenRouter embeddings.
multi sub OpenRouterEmbeddings($prompt,
                              :$model is copy = Whatever,
                              :$encoding-format is copy = Whatever,
                              :api-key(:$auth-key) is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'tiny',
                              Str :$base-url = 'https://openrouter.ai/api/v1') {

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'openrouter/free'; }
    die "The argument \$model is expected to be Whatever or a model identifier such as 'openrouter/free'."
    unless $model ~~ Str && $model.trim.chars && ($model eq 'openrouter/free' || $model.contains('/'));

    #------------------------------------------------------
    # Process $encoding-format
    #------------------------------------------------------
    if $encoding-format.isa(Whatever) { $encoding-format = 'float'; }
    die "The argument \$encoding-format is expected to be Whatever or one of the strings 'float' or 'base64'."
    unless $encoding-format ~~ Str && $encoding-format.lc ∈ <float base64>;

    #------------------------------------------------------
    # OpenRouter URL
    #------------------------------------------------------

    my $url = $base-url ~ '/embeddings';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    my $input = $prompt ~~ Positional || $prompt ~~ Seq
        ?? $prompt.Array
        !! $prompt.Str;
    return openrouter-request(:$url,
            body => to-json({ input => $input, :$model, encoding_format => $encoding-format }),
            :$auth-key, :$timeout, :$format, :$method);
}
