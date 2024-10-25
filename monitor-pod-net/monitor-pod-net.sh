#!/bin/bash

pod=""
namespace=""
tcpdump_options=""

help() {
    echo "Usage: $0 [options]"
    echo  "Options:"
    echo  "  -h, --help      Display help"
    echo  "  -pod            Pod name"
    echo  "  -namespace      Namespace"
    echo  "  -tcpdump        tcpdump options"
}

monitor_pod_net() {
    docker_id=$(kubectl get pod $pod -n $namespace  -o jsonpath='{.status.containerStatuses[0].containerID}' | cut -d '/' -f 3)
    docker_pid=$(docker inspect $docker_id | jq '.[0].State.Pid')
    network_index=$(nsenter -t $docker_pid -n ip addr | grep eth0@ | cut -d ':' -f 2 | sed 's/eth0@if//g')
    network_name=$(ip a | grep $network_index | cut -d ':' -f 2 | cut -d '@' -f 1)
    tcpdump -i $network_name $tcpdump_options
}

main() {
    if [ $# -eq 0 ]; then
        help
        exit 1
    fi

    while [ "$1" != "" ]; do
        case $1 in
            -pod )          shift
                            pod=$1
                            ;;
            -namespace )    shift
                            namespace=$1
                            ;;
            -tcpdump )      shift
                            tcpdump_options=$1
                            ;;
            -h | --help )   help
                            exit
                            ;;
            * )             help
                            exit 1
        esac
        shift
    done

    monitor_pod_net
}

main "$@"