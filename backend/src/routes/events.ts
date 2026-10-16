import { FastifyInstance } from 'fastify';

export default async function eventsRoutes(fastify: FastifyInstance) {
  // GET /api/events — Server-Sent Events stream of live call activity
  fastify.get('/events', (request, reply) => {
    reply.hijack();
    const res = reply.raw;

    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
      'X-Accel-Buffering': 'no',
      'Access-Control-Allow-Origin': request.headers.origin ?? '*',
    });
    res.write(': connected\n\n');

    const unsubscribe = fastify.liveEvents.subscribe((event, payload) => {
      res.write(`event: ${event}\ndata: ${JSON.stringify(payload)}\n\n`);
    });

    // Keep proxies / free hosts from closing an idle stream
    const heartbeat = setInterval(() => res.write(': ping\n\n'), 25000);

    request.raw.on('close', () => {
      clearInterval(heartbeat);
      unsubscribe();
    });
  });
}
