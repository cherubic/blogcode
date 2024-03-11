#!/bin/bash

linux-build() {
    docker build -t remotedlv:v0.0.1 . -f dockerfile/Dockerfile.dev
    
    docker run -d --name remotedlv remotedlv:v0.0.1

    docker cp remotedlv:/app/remotedlv ./remotedlv

    docker stop remotedlv && docker rm remotedlv
}

docker_start() {
    if [ ! "$(docker ps -q -f name=remotedlv)" ]; then
        if [ "$(docker ps -aq -f status=exited -f name=remotedlv)" ]; then
            docker start remotedlv
        else
            docker run -d --name remotedlv -p 4000:4000 -p 2345:2345 remotedlv:v0.0.1
        fi
    fi
}

main() {
    local subcommand=$1

    case $subcommand in
        build)
            linux-build
            ;;
        run)
            docker_start
            ;;
        *)
            echo "Invalid subcommand: $subcommand"
            echo "Usage: $0 {build|run}"
            echo "  build: build the application dev binary and Docker image"
            echo "  run: run the Docker container"
            exit 1
            ;;
    esac
}

main "$@"