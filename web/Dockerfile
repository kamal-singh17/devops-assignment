	FROM nginx:alpine

# Create non-root user
RUN adduser -D -u 1001 appuser

# Copy custom config
COPY nginx.conf /etc/nginx/nginx.conf

# Fix permissions
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx \
    && chown -R 1001:1001 /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html /tmp

USER 1001

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
