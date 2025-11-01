# build stage
FROM alpine:latest AS builder

# create app directory and copy files
WORKDIR /app
COPY index.html .

# final image
FROM nginx:alpine

# Copy built files from builder stage
COPY --from=builder /app /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

