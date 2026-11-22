// Temple AI proxy: receives a meal description and/or a photo, asks Gemini for an estimate,
// returns {items:[{name, grams, kcal, protein_g}]}. The Gemini key lives only in Cloudflare secrets.
const PROMPT = `You are a nutrition estimator. Identify each food in the meal (from the photo and/or the description) and estimate grams, calories (kcal) and protein (g) for the portion shown or described. Reply ONLY with JSON: {"items":[{"name":string,"grams":number,"kcal":number,"protein_g":number}]}. Use short food names in the user's language. If nothing edible is described, return {"items":[]}.`;

export default {
  async fetch(req, env) {
    if (req.method !== "POST") return new Response("POST only", { status: 405 });
    if (env.APP_SECRET && req.headers.get("x-app-secret") !== env.APP_SECRET) return new Response("Unauthorized", { status: 401 });
    let body;
    try { body = await req.json(); } catch { return new Response("Bad JSON", { status: 400 }); }
    const { text, imageBase64 } = body;
    if (!text && !imageBase64) return new Response("Send text and/or imageBase64", { status: 400 });

    const parts = [{ text: PROMPT + (text ? `\nDescription: ${text}` : "") }];
    if (imageBase64) parts.push({ inline_data: { mime_type: "image/jpeg", data: imageBase64 } });

    // Try MODEL first, then optional FALLBACK_MODELS (comma separated); retry busy errors (429/500/503) briefly.
    const models = [env.MODEL || "gemini-3.6-flash", ...(env.FALLBACK_MODELS || "").split(",").map(s => s.trim()).filter(Boolean)];
    const payload = JSON.stringify({ contents: [{ parts }], generationConfig: { responseMimeType: "application/json", temperature: 0.2, maxOutputTokens: 4096 } });
    let r;
    for (const model of models) {
      for (let attempt = 0; attempt < 2; attempt++) {
        r = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`, {
          method: "POST",
          headers: { "content-type": "application/json", "x-goog-api-key": env.GEMINI_API_KEY },
          body: payload,
        });
        if (r.ok || ![429, 500, 503].includes(r.status)) break;
        await new Promise(res => setTimeout(res, 1500));
      }
      if (r.ok || ![429, 500, 503, 404].includes(r.status)) break;
    }
    if (!r.ok) return new Response(`Gemini error ${r.status}: ${(await r.text()).slice(0, 250)}`, { status: 502 });
    const data = await r.json();
    // Newer Gemini models may return several parts (thoughts, fenced code): join the text parts and pull out the JSON object.
    const raw = (data?.candidates?.[0]?.content?.parts ?? []).filter(p => !p.thought && typeof p.text === "string").map(p => p.text).join("");
    let parsed;
    try {
      const m = raw.match(/\{[\s\S]*\}/);
      parsed = JSON.parse(m ? m[0] : raw);
    } catch {
      const why = data?.candidates?.[0]?.finishReason || data?.promptFeedback?.blockReason || "unknown";
      return new Response(`Model returned invalid JSON (finish: ${why}): ${raw.slice(0, 200)}`, { status: 502 });
    }
    return new Response(JSON.stringify({ items: Array.isArray(parsed.items) ? parsed.items : [] }), { headers: { "content-type": "application/json" } });
  },
};
