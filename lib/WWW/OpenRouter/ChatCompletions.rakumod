unit module WWW::OpenRouter::ChatCompletions;

use WWW::OpenRouter::Models;
use WWW::OpenRouter::Request;
use JSON::Fast;

#============================================================
# Known roles
#============================================================

my $knownRoles = Set.new(<user assistant>);


#============================================================
# Completions
#============================================================

#| OpenRouter completion access.
our proto OpenRouterChatCompletion($prompt is copy,
                                  :$role is copy = Whatever,
                                  :$model is copy = Whatever,
                                  :$temperature is copy = Whatever,
                                  :$max-tokens is copy = Whatever,
                                  Numeric :$top-p = 1,
                                  Bool :$stream = False,
                                  :$random-seed is copy = Whatever,
                                  :api-key(:$auth-key) is copy = Whatever,
                                  UInt :$timeout= 10,
                                  :$format is copy = Whatever,
                                  Str :$method = 'tiny',
                                  Str :$base-url = 'https://openrouter.ai/api/v1') is export {*}

#| OpenRouter completion access.
multi sub OpenRouterChatCompletion(Str $prompt, *%args) {
    return OpenRouterChatCompletion([$prompt,], |%args);
}

#| OpenRouter completion access.
multi sub OpenRouterChatCompletion(@prompts is copy,
                                  :$role is copy = Whatever,
                                  :$model is copy = Whatever,
                                  :$temperature is copy = Whatever,
                                  :$max-tokens is copy = Whatever,
                                  Numeric :$top-p = 1,
                                  Bool :$stream = False,
                                  :$random-seed is copy = Whatever,
                                  :api-key(:$auth-key) is copy = Whatever,
                                  UInt :$timeout= 10,
                                  :$format is copy = Whatever,
                                  Str :$method = 'tiny',
                                  Str :$base-url = 'https://openrouter.ai/api/v1') {

    #------------------------------------------------------
    # Process $role
    #------------------------------------------------------
    if $role.isa(Whatever) { $role = "user"; }
    die "The argument \$role is expected to be Whatever or one of the strings: { '"' ~ $knownRoles.keys.sort.join('", "') ~ '"' }."
    unless $role ∈ $knownRoles;

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'openrouter/free'; }
    die "The argument \$model is expected to be Whatever or a model identifier such as 'openrouter/free'."
    unless $model ~~ Str && $model.trim.chars && ($model eq 'openrouter/free' || $model.contains('/'));

    #------------------------------------------------------
    # Process $temperature
    #------------------------------------------------------
    if $temperature.isa(Whatever) { $temperature = 0.7; }
    die "The argument \$temperature is expected to be Whatever or number between 0 and 2."
    unless $temperature ~~ Numeric && 0 ≤ $temperature ≤ 2;

    #------------------------------------------------------
    # Process $max-tokens
    #------------------------------------------------------
    if $max-tokens.isa(Whatever) { $max-tokens = 4096; }
    die "The argument \$max-tokens is expected to be Whatever or a positive integer."
    unless $max-tokens ~~ Int && 0 < $max-tokens;

    #------------------------------------------------------
    # Process $top-p
    #------------------------------------------------------
    if $top-p.isa(Whatever) { $top-p = 1.0; }
    die "The argument \$top-p is expected to be Whatever or number between 0 and 1."
    unless $top-p ~~ Numeric && 0 ≤ $top-p ≤ 1;

    #------------------------------------------------------
    # Process $stream
    #------------------------------------------------------
    die "The argument \$stream is expected to be Boolean."
    unless $stream ~~ Bool;

    #------------------------------------------------------
    # Process $random-seed
    #------------------------------------------------------
    die "The argument \$random-seed is expected to be a integer or Whatever."
    unless $random-seed.isa(Whatever) || $random-seed ~~ Int;

    #------------------------------------------------------
    # Messages
    #------------------------------------------------------
    my @messages = @prompts.map({
        if $_ ~~ Pair {
            die "Unknown message role: {$_.key}" unless $_.key ∈ $knownRoles;
            %(role => $_.key, content => $_.value)
        } else {
            %(:$role, content => $_)
        }
    });

    #------------------------------------------------------
    # Make OpenRouter URL
    #------------------------------------------------------

    my %body = :$model, :$temperature, :$stream,
               top_p => $top-p,
               :@messages,
               max_tokens => $max-tokens;

    if $random-seed ~~ Int:D {
        %body.push('random_seed' => $random-seed);
    }

    my $url = $base-url ~ '/chat/completions';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openrouter-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);
}
