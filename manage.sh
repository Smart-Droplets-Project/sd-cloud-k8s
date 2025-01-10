#!/bin/bash

K8S_DIR="k8s"

start() {
    echo "Starting all Kubernetes resources..."
    for component_dir in "$K8S_DIR"/*/; do
        echo "Applying resources in $component_dir..."
        kubectl apply -f "$component_dir"
    done
    echo "All resources have been started."
}

stop() {
    echo "Stopping all Kubernetes resources..."
    for component_dir in "$K8S_DIR"/*/; do
        echo "Deleting resources in $component_dir..."
        kubectl delete -f "$component_dir"
    done
    echo "All resources have been stopped."
}

usage() {
    echo "Usage: $0 {start|stop}"
    echo "  start: Spin up all Kubernetes resources."
    echo "  stop: Shut down all Kubernetes resources."
}



if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        usage
        exit 1
        ;;
esac
