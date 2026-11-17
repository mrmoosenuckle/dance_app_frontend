# dance_app_frontend

## Deployment

Build and run the production web image with Nginx:

```sh
docker build -t dance-app-frontend .
docker run --rm -p 8080:80 dance-app-frontend
```

The production web image sends `/api/` requests to Nginx on the same origin.
Nginx forwards them to `http://192.168.127.213:3000`, where the NAS exposes the
API. The frontend container must be able to reach that address and port.

When running the web app outside the Docker image, it uses port `3000` on the
browser's current host by default. This requires the API to allow the web
app's origin via CORS.

Non-web builds use `http://192.168.127.213:3000/api` by default, so the device
must be able to reach the NAS on port `3000`.