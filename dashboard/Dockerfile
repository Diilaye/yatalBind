###############################################
# FILE: dahsboard/Dockerfile
# Dashboard: Pre-built Flutter web + Nginx
# Copy du build pre-compilé depuis site-web-dashboard/web
###############################################

FROM nginx:alpine

# Copy pre-built Flutter web files
COPY site-web-dashboard/web /usr/share/nginx/html

# Copy Nginx config
COPY dashboard/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3001 || exit 1

CMD ["nginx", "-g", "daemon off;"]
