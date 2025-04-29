# Use an official Nginx image to serve static files
FROM nginx:stable-alpine

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy our static website (adjust paths if needed)
COPY ./html /usr/share/nginx/html
COPY ./assets /usr/share/nginx/html/assets
COPY ./css /usr/share/nginx/html/css
COPY ./js /usr/share/nginx/html/js

# Expose port 80 (default), Cloud Run maps to 8080 automatically
EXPOSE 80

# Start nginx in foreground (required for container)
CMD ["nginx", "-g", "daemon off;"]
