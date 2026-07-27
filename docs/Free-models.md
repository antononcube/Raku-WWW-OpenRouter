# OpenRouter free models

The Models API returns pricing information for every model, so you can identify free ones programmatically.

### How free models appear

- Pricing fields (`prompt` and `completion`) are strings in USD per token.
- A value of `"0"` means that part is free.
- Many free variants also have an ID ending in `:free` (e.g. `deepseek/deepseek-r1:free`).

### Example: list only free models with curl + jq

```bash
curl -s "https://openrouter.ai/api/v1/models?limit=500" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  | jq -r '.data[] | select(.pricing.prompt == "0" and .pricing.completion == "0") | .id'
```

This prints the IDs of models where both input and output are free.

### Slightly more detail (ID + pricing)

```bash
curl -s "https://openrouter.ai/api/v1/models?limit=500" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  | jq '.data[] | select(.pricing.prompt == "0" and .pricing.completion == "0") | {id, pricing}'
```

### Bonus: Free Models Router

You can also just use the special router that automatically picks a free model:

```bash
# model: "openrouter/free"
```

**Note:** Free models usually have rate limits (e.g. requests per minute/day). Check the current limits in the OpenRouter docs or on the models page.