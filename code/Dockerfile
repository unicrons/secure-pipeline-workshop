FROM node:24-alpine

RUN addgroup -g 1001 -S nodejs && \
  adduser -S nextjs -u 1001 -G nodejs

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production && \
  npm cache clean --force

COPY --chown=nextjs:nodejs src/ ./src/

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

USER nextjs

CMD ["npm", "start"]
