# Use the official NGINX image from Docker Hub
FROM nginx:alpine

# Copy the static content of your website into the NGINX html directory
# We will create a 'src' folder for the website code shortly.
COPY src/ /usr/share/nginx/html

# Expose port 80
EXPOSE 80
