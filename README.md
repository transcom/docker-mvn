# docker-mvn

This creates a docker image built off of CircleCI's most basic convenience image [`cimg/base`](https://hub.docker.com/r/cimg/base) with the following tools installed on top:

- AWS CLI
- CircleCI CLI
- ShellCheck
- Github CLI
- Maven CLI
- SAM CLI

It is intended to provide support necessary for Java applications within MilMove.

## Developer Setup

```sh
brew install pre-commit docker
```