
unit module WWW::OpenRouter::Models;

use WWW::OpenRouter::Request;
use JSON::Fast;

our sub openrouter-known-models(
        :api-key(:$auth-key) = Whatever,
        UInt:D :$timeout = 10,
        Str:D :$base-url = 'https://openrouter.ai/api/v1',
        Str:D :$method = 'tiny'
                                ) is export {
    state %model-cache;
    return %model-cache{$base-url} if %model-cache{$base-url}:exists;

    my $url = $base-url ~ '/models';
    my $result = openrouter-request(:$url, body => '', :$auth-key,
                                    :$timeout, format => 'hash', :$method);
    my @models = $result ~~ Map && ($result<data>:exists)
        ?? $result<data>.Array
        !! $result ~~ Positional ?? $result.Array !! [];
    %model-cache{$base-url} = @models.grep(* ~~ Map).map({ .<id> => $_ }).Hash;
    return %model-cache{$base-url};
}
