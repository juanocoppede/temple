# Temple AI proxy
1. Get a free Gemini key at https://aistudio.google.com/apikey
2. `npm i -g wrangler && wrangler login`
3. In this folder: `wrangler secret put GEMINI_API_KEY` (paste the key), `wrangler secret put APP_SECRET` (invent any long password)
4. `wrangler deploy` → it prints your URL (https://temple-ai.<you>.workers.dev)
5. In the app: Nutrition → gear icon → paste the URL and the APP_SECRET.
If the default model name is rejected, set `MODEL` in wrangler.toml `[vars]` to a current Gemini Flash model.
