# OpenRouter `curl` examples

----

## Chat completion

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d '{
    "model": "openai/gpt-4o-mini",
    "messages": [
      {
        "role": "user",
        "content": "What is the meaning of life?"
      }
    ]
  }'
```

----

## Embeddings

```bash
curl https://openrouter.ai/api/v1/embeddings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d '{
    "model": "openai/text-embedding-3-small",
    "input": "The quick brown fox jumps over the lazy dog"
  }'
```

For multiple texts in one request, pass an array:

```bash
curl https://openrouter.ai/api/v1/embeddings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d '{
    "model": "openai/text-embedding-3-small",
    "input": [
      "The quick brown fox jumps over the lazy dog",
      "Hello world"
    ]
  }'
```

Both endpoints are OpenAI-compatible. Browse available models (including embedding ones) at [openrouter.ai/models](https://openrouter.ai/models).

----

## Models

Use the **Models API** endpoint:

```bash
curl https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer $OPENROUTER_API_KEY"
```

### Useful variations

**Get more results (pagination):**

```bash
curl "https://openrouter.ai/api/v1/models?limit=500" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY"
```

**Filter by modality** (text is the default):

```bash
# Image generation models only
curl "https://openrouter.ai/api/v1/models?output_modalities=image" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY"

# Embeddings
curl "https://openrouter.ai/api/v1/models?output_modalities=embeddings" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY"

# All modalities
curl "https://openrouter.ai/api/v1/models?output_modalities=all" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY"
```

The response is a JSON object with a `data` array. Each entry includes the model `id` (the slug you use in requests, e.g. `openai/gpt-4o-mini`), pricing, context length, supported parameters, and other metadata.

**Tip:** Pipe the output through `jq` to extract just the model IDs:

```bash
curl -s https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" | jq -r '.data[].id'
```