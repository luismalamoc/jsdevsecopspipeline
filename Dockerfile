# Stage 1: Build
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:20-alpine
WORKDIR /app

# Config user
RUN addgroup -S node && adduser -S node -G node

# Copy dependencies and built app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./

# Change ownership
RUN chown -R node:node /app

# Change user
USER node:node

# Expose
EXPOSE 3000

# Execute
CMD ["node", "dist/main.js"]
