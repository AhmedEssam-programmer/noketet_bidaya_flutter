import 'dotenv/config';
import express from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.post('/chat', async (req, res) => {
  try {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      return res.status(500).json({
        error: 'Missing OPENAI_API_KEY on server. Add it to backend/.env then restart.',
      });
    }

    const message = (req.body?.message ?? '').toString().trim();
    if (!message) {
      return res.status(400).json({ error: 'message is required' });
    }

    const model = (req.body?.model ?? process.env.OPENAI_MODEL ?? 'gpt-4.1-mini').toString();
    const system = (req.body?.system ?? process.env.SYSTEM_PROMPT ?? 'You are a helpful assistant. Reply in Arabic when the user writes Arabic.').toString();

    const upstream = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: message },
        ],
      }),
    });

    const data = await upstream.json().catch(() => null);
    if (!upstream.ok) {
      const upstreamError =
        data?.error?.message ??
        data?.error ??
        `Upstream error (status ${upstream.status})`;
      return res.status(502).json({ error: upstreamError });
    }

    const reply = data?.choices?.[0]?.message?.content?.toString() ?? '';
    return res.json({ reply });
  } catch (e) {
    return res.status(500).json({ error: e?.toString?.() ?? 'Unknown server error' });
  }
});

const port = Number(process.env.PORT ?? 3000);
app.listen(port, '0.0.0.0', () => {
  // eslint-disable-next-line no-console
  console.log(`Chat backend listening on http://localhost:${port}`);
});

