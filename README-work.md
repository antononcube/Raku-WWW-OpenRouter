# WWW::OpenRouter

## In brief

This Raku package provides API access to the Large Language Models (LLMs) service [OpenRouter](https://openrouter.ai), [OR1].
For more details of the OpenRouter's API usage see [the documentation](https://openrouter.ai/docs), [OR2].

**Remark:** To use the OpenRouter API one has to register and obtain authorization key.

This package is very similar to the packages
["WWW::OpenAI"](https://github.com/antononcube/Raku-WWW-OpenAI), [AAp1], and
["WWW::Gemini"](https://github.com/antononcube/Raku-WWW-Gemini), [AAp2].

"WWW::OpenRouter" can be used with (is integrated with)
["LLM::Functions"](https://github.com/antononcube/Raku-LLM-Functions), [AAp3], and
["Jupyter::Chatbook"](https://github.com/antononcube/Raku-Jupyter-Chatbook), [AAp5].

Also, of course, prompts from
["LLM::Prompts"](https://github.com/antononcube/Raku-LLM-Prompts), [AAp4],
can be used with OpenRouter's functions.

-----

## Installation

Package installations from both sources use [zef installer](https://github.com/ugexe/zef)
(which should be bundled with the "standard" Rakudo installation file.)

To install the package from [Zef ecosystem](https://raku.land/) use the shell command:

```
zef install WWW::OpenRouter
```

To install the package from the GitHub repository use the shell command:

```
zef install https://github.com/antononcube/Raku-WWW-OpenRouter.git
```

---

## Universal "front-end"

The package has an universal "front-end" function `openrouter-playground` for the
[different functionalities provided by OpenRouter](https://openrouter.ai/docs).

Here is a simple call for a "chat completion":

```raku
use WWW::OpenRouter;
openrouter-playground('Where is Roger Rabbit?');
```

**Remark:** When the authorization key, `auth-key`, is specified to be `Whatever`
then the functions `openrouter-*` attempt to use the env variable `OPENROUTER_API_KEY`.

Another one using Bulgarian:

```raku
openrouter-playground('Колко групи могат да се намерят в този облак от точки.', max-tokens => 300, format => 'values');
```

**Remark:** The functions `openrouter-chat-completion` or `openrouter-completion` can be used instead in the examples above.
(The latter is synonym of the former.)


### Models

The current OpenRouter models can be found with the function `openrouter-models`:

```raku
openrouter-models.elems;
```

----

## Code generation

There are two types of completions : text and chat. Let us illustrate the differences
of their usage by Raku code generation. Here is a text completion:

```raku
openrouter-completion(
        'generate Raku code for making a loop over a list',
        max-tokens => 1024,
        format => 'values');
```

Here is a chat completion:

```raku, results=asis
openrouter-completion(
        'generate Raku code for making a loop over a list',
        max-tokens => 1024,
        format => 'values');
```

----

## Embeddings

Embeddings can be obtained with the function `openrouter-embeddings`. Here is an example of finding the embedding vectors
for each of the elements of an array of strings:

```raku
my @queries = [
    'make a classifier with the method RandomForeset over the data dfTitanic',
    'show precision and accuracy',
    'plot True Positive Rate vs Positive Predictive Value',
    'what is a good meat and potatoes recipe'
];

my $model = 'nvidia/nemotron-3-embed-1b:free';
my $embs = openrouter-embeddings(@queries, format => 'values', :$model);
$embs.elems;
```

Here we show:
- That the result is an array of four vectors each with length 1536
- The distributions of the values of each vector

```raku
use Data::Reshapers;
use Data::Summarizers;

say "\$embs.elems : { $embs.elems }";
say "\$embs>>.elems : { $embs>>.elems }";
records-summary($embs.kv.Hash.&transpose);
```

Here we find the corresponding dot products and (cross-)tabulate them:

```raku
my @ct = (^$embs.elems X ^$embs.elems).map({ %( i => $_[0], j => $_[1], dot => sum($embs[$_[0]] >>*<< $embs[$_[1]])) }).Array;

say to-pretty-table(cross-tabulate(@ct, 'i', 'j', 'dot'), field-names => (^$embs.elems)>>.Str);
````

**Remark:** Note that the fourth element (the cooking recipe request) is an outlier.
(Judging by the table with dot products.)

----

## Chat completions with engineered prompts

Here is a prompt for "emojification" (see the
[Wolfram Prompt Repository](https://resources.wolframcloud.com/PromptRepository/)
entry
["Emojify"](https://resources.wolframcloud.com/PromptRepository/resources/Emojify/)):

```raku
my $preEmojify = q:to/END/;
Rewrite the following text and convert some of it into emojis.
The emojis are all related to whatever is in the text.
Keep a lot of the text, but convert key words into emojis.
Do not modify the text except to add emoji.
Respond only with the modified text, do not include any summary or explanation.
Do not respond with only emoji, most of the text should remain as normal words.
END
```

Here is an example of chat completion with emojification:

```raku
[
    assistant => $preEmojify,
    user => 'Python sucks, Raku rocks, and Perl is annoying'
]
==> openrouter-chat-completion(:1024max-tokens, format => 'values')
```

-------

## Command Line Interface

### Playground access

The package provides a Command Line Interface (CLI) script:

```shell
openrouter-playground --help
```

**Remark:** When the authorization key argument "auth-key" is specified set to "Whatever"
then `openrouter-playground` attempts to use the env variable `OPENROUTER_API_KEY`.


--------

## Mermaid diagram

The following flowchart corresponds to the steps in the package function `openrouter-playground`:

```mermaid
graph TD
	UI[/Some natural language text/]
	TO[/"OpenRouter<br/>Processed output"/]
	WR[[Web request]]
	OpenRouter{{https://openrouter.ai/api}}
	PJ[Parse JSON]
	Q{Return<br>hash?}
	MSTC[Compose query]
	MURL[[Make URL]]
	TTC[Process]
	QAK{Auth key<br>supplied?}
	EAK[["Try to find<br>OPENROUTER_API_KEY<br>in %*ENV"]]
	QEAF{Auth key<br>found?}
	NAK[/Cannot find auth key/]
	UI --> QAK
	QAK --> |yes|MSTC
	QAK --> |no|EAK
	EAK --> QEAF
	MSTC --> TTC
	QEAF --> |no|NAK
	QEAF --> |yes|TTC
	TTC -.-> MURL -.-> WR -.-> TTC
	WR -.-> |URL|OpenRouter 
	OpenRouter -.-> |JSON|WR
	TTC --> Q 
	Q --> |yes|PJ
	Q --> |no|TO
	PJ --> TO
```

--------

## References

### Dashboard & documentation

[OR1] OpenRouter, Inc., [OpenRouter dashboard](https://openrouter.ai).

[OR2] OpenRouter, Inc., [OpenRouter documentation](https://openrouter.ai/docs).

### Packages

[AAp1] Anton Antonov,
[WWW::OpenAI Raku package](https://github.com/antononcube/Raku-WWW-OpenAI),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[WWW::Gemini Raku package](https://github.com/antononcube/Raku-WWW-Gemini),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[LLM::Functions Raku package](https://github.com/antononcube/Raku-LLM-Functions),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[LLM::Prompts Raku package](https://github.com/antononcube/Raku-LLM-Prompts),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Jupyter::Chatbook Raku package](https://github.com/antononcube/Raku-Jupyter-Chatbook),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).