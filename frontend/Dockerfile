FROM nginx:stable-alpine

# Clear default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy all needed frontend content into html root
COPY frontend/html /usr/share/nginx/html
COPY frontend/assets /usr/share/nginx/html/assets
COPY frontend/css /usr/share/nginx/html/css
COPY frontend/js /usr/share/nginx/html/js

COPY frontend/nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]