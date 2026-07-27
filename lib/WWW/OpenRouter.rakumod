 unit module WWW::OpenRouter;

use JSON::Fast;
use HTTP::Tiny;

use WWW::OpenRouter::ChatCompletions;
use WWW::OpenRouter::Embeddings;
use WWW::OpenRouter::Models;
use WWW::OpenRouter::Request;

#===========================================================
#| Gives the base URL of OpenAI's endpoints.
our sub openrouter-base-url(-->Str) is export { return 'https://openrouter.ai/api/v1';}


#===========================================================
#| OpenRouter chat completions access. (Synonym of openrouter-chat-completion.)
#| C<$prompt> -- message(s) to the LLM;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$stream> -- whether to stream the result or not;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
sub openrouter-completion(**@args, *%args) is export {
   return openrouter-chat-completion(|@args, |%args);
}


#===========================================================
#| OpenRouter chat completions access.
#| C<$prompt> -- message(s) to the LLM;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$stream> -- whether to stream the result or not;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openrouter-chat-completion(|) is export {*}

multi sub openrouter-chat-completion(**@args, *%args) {
    return WWW::OpenRouter::ChatCompletions::OpenRouterChatCompletion(|@args, |%args);
}

#===========================================================
#| OpenRouter embeddings access.
#| C<$prompt> -- prompt to make embeddings for;
#| C<:$model> -- model;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openrouter-embeddings(|) is export {*}

multi sub openrouter-embeddings(**@args, *%args) {
    return WWW::OpenRouter::Embeddings::OpenRouterEmbeddings(|@args, |%args);
}

#===========================================================
#| OpenRouter models access.
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout.
our proto openrouter-models(|) is export {*}

multi sub openrouter-models(
        :api-key(:$auth-key) = Whatever,
        UInt :$timeout = 10,
        :$format = Whatever,
        Str :$method = 'tiny',
        Str :$base-url = openrouter-base-url) {
    my $url = $base-url ~ '/models';
    return openrouter-request(:$url, body => '', :$auth-key, :$timeout,
                              :$format, :$method);
}

#============================================================
# Playground
#============================================================

#| OpenRouter playground access.
#| C<:path> -- end point path;
#| C<:api-key(:$auth-key)> -- authorization key (API key);
#| C<:timeout> -- timeout
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>,
#| C<*%args> -- additional arguments, see C<openrouter-chat-completion> and C<openrouter-text-completion>.
our proto openrouter-playground($text is copy = '',
                               Str :$path = 'completions',
                               :api-key(:$auth-key) is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny',
                               Str :$base-url = 'https://openrouter.ai/api/v1',
                               *%args
                               ) is export {*}

#| OpenRouter playground access.
multi sub openrouter-playground(*%args) {
    return openrouter-playground('', |%args);
}

#| OpenRouter playground access.
multi sub openrouter-playground(@texts, *%args) {
    return @texts.map({ openrouter-playground($_, |%args) });
}

#| OpenRouter playground access.
multi sub openrouter-playground($text is copy,
                               Str :$path = 'completions',
                               :api-key(:$auth-key) is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny',
                               Str :$base-url = 'https://openrouter.ai/api/v1',
                               *%args
                               ) {

    #------------------------------------------------------
    # Dispatch
    #------------------------------------------------------
    given $path.lc {
        when $_ eq 'models' {
            # my $url = 'https://openrouter.ai/api/v1/models';
            return openrouter-models(:$auth-key, :$timeout, :$method, :$base-url, :$format);
        }
        when $_ ∈ <completion completions chat/completions> {
            # my $url = 'https://openrouter.ai/api/v1/chat/completions';
            my $expectedKeys = <model prompt max-tokens temperature top-p stream echo random-seed>;
            return openrouter-chat-completion($text,
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <embedding embeddings> {
            # my $url = 'https://openrouter.ai/api/v1/embeddings';
            return openrouter-embeddings($text,
                    |%args.grep({ $_.key ∈ <model encoding-format> }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        default {
            die 'Do not know how to process the given path.';
        }
    }
}
