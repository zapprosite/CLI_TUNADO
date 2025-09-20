import Fastify from 'fastify';
import pino from 'pino';
import { z } from 'zod';

const PORT = Number(process.env.PORT || 3300);
const logger = pino({ level: process.env.LOG_LEVEL || 'info' });
const app = Fastify({ logger });

app.get('/healthz', async () => ({ ok: true }));

// In-memory todos (v1)
type Todo = { id: number; title: string; done: boolean };
const todos: Todo[] = [
  { id: 1, title: 'Hello world', done: false },
];

const TodoCreate = z.object({ title: z.string().min(1) });
const TodoUpdate = z.object({ title: z.string().min(1).optional(), done: z.boolean().optional() });

app.get('/api/todos', async () => todos);

app.post('/api/todos', async (req, res) => {
  const body = TodoCreate.safeParse(req.body);
  if (!body.success) return res.status(400).send({ error: 'Invalid body' });
  const id = todos.length ? Math.max(...todos.map(t => t.id)) + 1 : 1;
  const todo = { id, title: body.data.title, done: false };
  todos.push(todo);
  return res.status(201).send(todo);
});

app.put('/api/todos/:id', async (req, res) => {
  const id = Number((req.params as any).id);
  const body = TodoUpdate.safeParse(req.body);
  if (!Number.isFinite(id)) return res.status(400).send({ error: 'Invalid id' });
  if (!body.success) return res.status(400).send({ error: 'Invalid body' });
  const idx = todos.findIndex(t => t.id === id);
  if (idx === -1) return res.status(404).send({ error: 'Not found' });
  todos[idx] = { ...todos[idx], ...body.data };
  return res.send(todos[idx]);
});

app.delete('/api/todos/:id', async (req, res) => {
  const id = Number((req.params as any).id);
  const idx = todos.findIndex(t => t.id === id);
  if (idx === -1) return res.status(404).send({ error: 'Not found' });
  const [deleted] = todos.splice(idx, 1);
  return res.send(deleted);
});

app.listen({ port: PORT, host: '0.0.0.0' }, (err, address) => {
  if (err) {
    app.log.error(err);
    process.exit(1);
  }
  app.log.info(`api listening on ${address}`);
});

