# ===========================================
# ClaimsAgent — everything in one image
# Postgres (with demo data) + PostgREST + Fastify backend + React dashboard behind nginx.
# No external database needed. Listens on $PORT (default 8080).
# ===========================================

FROM node:22-alpine AS backend-build
WORKDIR /app
COPY backend/package*.json ./
RUN npm ci
COPY backend/ ./
RUN npm run build && npm prune --omit=dev

FROM node:22-alpine AS frontend-build
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
# "/" = same origin: nginx serves /api and /rest/v1 next to the dashboard
ARG VITE_ELEVENLABS_AGENT_ID=agent_7501m0x4yxp4e009xm0f3hxxxq1g
ENV VITE_API_URL=/ \
    VITE_SUPABASE_URL=/ \
    VITE_SUPABASE_ANON_KEY=local \
    VITE_ELEVENLABS_AGENT_ID=$VITE_ELEVENLABS_AGENT_ID
RUN npm run build

FROM postgrest/postgrest:v12.2.12 AS postgrest

FROM node:22-alpine
RUN apk add --no-cache bash postgresql16 nginx gettext
COPY --from=postgrest /bin/postgrest /usr/local/bin/postgrest

WORKDIR /app
COPY --from=backend-build /app/dist ./backend/dist
COPY --from=backend-build /app/node_modules ./backend/node_modules
COPY --from=backend-build /app/package.json ./backend/package.json
COPY --from=frontend-build /app/dist ./web

# Loaded in filename order on every start
COPY docker/db/roles.sql                        ./db/00-roles.sql
COPY backend/database/migration.sql             ./db/10-schema.sql
COPY backend/database/0002_filecoin_columns.sql ./db/11-filecoin-columns.sql
COPY backend/database/0003_filecoin_tables.sql  ./db/12-filecoin-tables.sql
COPY backend/database/0004_call_log_analysis.sql ./db/13-call-log-analysis.sql
COPY backend/database/seed.sql                  ./db/20-seed.sql
COPY docker/db/demo-extras.sql                  ./db/21-demo-extras.sql
COPY docker/db/api-access.sql                   ./db/30-api-access.sql

COPY docker/nginx.conf.template ./nginx.conf.template
COPY docker/start.sh ./start.sh
RUN sed -i 's/\r$//' ./start.sh && chmod +x ./start.sh

# Non-root (uid 1000) — required by Hugging Face Spaces, fine everywhere else
USER node
ENV PORT=8080
EXPOSE 8080
CMD ["/app/start.sh"]
