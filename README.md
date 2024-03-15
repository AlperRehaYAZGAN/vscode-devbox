# OpenVSCode Server Docker Image  
This is the repository for the OpenVSCode Server Web UI Docker Image. You can just clone the repository and create your own browser based VSCode server.

Image is also available on Docker Hub: [alperreha/vsdevcenter](https://hub.docker.com/r/alperreha/vsdevcenter)  

This project aiming to provide a simple and easy to use web based VSCode server that can run on any platform (AWS - GCP - OnPrem). You can develop your code on the cloud or on your local machine with the same environment.

>Uh-oh! Its works on my machine! 😅

### Usage  

```bash
# RELEASE: openvscode-server-v1.87.0 (2024-03-12) 
# BUILD
docker buildx build -f Dockerfile \
    --platform linux/amd64 \
    -t alperreha/vsdevcenter:empty \
    --build-arg RELEASE_TAG=openvscode-server-v1.87.0 .

# RUN with ENV TOKEN=12345672345678
export TOKEN=MY_SECRET_TOKEN
docker run --name vsdevcenter -p 3000:3000 \
    -e TOKEN=$TOKEN \
    --platform linux/amd64 \
    -d alperreha/vsdevcenter:empty

# when container is running, you can access the web ui with the following url
http://localhost:3000/?tkn=$TOKEN  
```

### Environment Variables

- `TOKEN` - Secret token for authentication for web ui access.


