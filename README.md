# docker-template

This repository is meant to serve as both an example and a template for new docker images with our general format.

This particular example creates a docker image built off of CircleCI's most basic convenience image [`cimg/base`](https://hub.docker.com/r/cimg/base) with the following tools installed on top:

- AWS CLI
- CircleCI CLI
- ShellCheck

## Creating a new Docker Image

1. Clone this repo.
2. Replace every instance of `trussworks/docker-template` with the name of your new image.
3. Modify Dockerfile to create your own image.
4. Register the image in Docker Hub.
5. Set up CircleCI to build and release the image to Docker Hub.
