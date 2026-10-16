import fp from 'fastify-plugin';
import { EventEmitter } from 'node:events';
import { FastifyInstance } from 'fastify';

export type LiveEventName = 'tool-executed' | 'call-completed';
type LiveEventListener = (event: LiveEventName, payload: unknown) => void;

declare module 'fastify' {
  interface FastifyInstance {
    liveEvents: {
      publish: (event: LiveEventName, payload: unknown) => void;
      subscribe: (listener: LiveEventListener) => () => void;
    };
  }
}

// In-process pub/sub for the live dashboard (streamed to browsers by routes/events.ts)
export default fp(async function liveEventsPlugin(fastify: FastifyInstance) {
  const emitter = new EventEmitter();
  emitter.setMaxListeners(0);

  fastify.decorate('liveEvents', {
    publish: (event: LiveEventName, payload: unknown) => {
      emitter.emit('event', event, payload);
    },
    subscribe: (listener: LiveEventListener) => {
      emitter.on('event', listener);
      return () => {
        emitter.off('event', listener);
      };
    },
  });
}, {
  name: 'live-events',
});
