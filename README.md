# dance_app_frontend

## Deployment

Build and run the production web image with Nginx:

```sh
docker build -t dance-app-frontend .
docker run --rm -p 8080:80 dance-app-frontend
```

The web application derives its API URL from the browser's current host and
uses port `3000` with the `/api` path. For example, opening
`http://203.0.113.10:8080` calls `http://203.0.113.10:3000/api`. Deploy the API
on port `3000` at the same host and with the same HTTP/HTTPS scheme as the
frontend.