#!/bin/bash

apply() {
    cd vpc
    terraform init
    terraform apply -auto-approve
    cd ../database
    terraform init
    terraform apply -auto-approve
}

destroy() {
    cd database
    terraform destroy -auto-approve
    cd ../vpc
    terraform destroy -auto-approve
}

case "$1" in
    "apply")
        apply
        ;;
    "destroy")
        destroy
        ;;
    *)
esac