#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

umask 0022
unset IFS
unset OFS
unset LD_PRELOAD
unset LD_LIBRARY_PATH

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

ARTIFACTS_LIST="res/artifacts.txt"
REGISTRY_DIR="res/registry"
RES_BIN="res/bin"
SKOPEO=${SKOPEO:-"${RES_BIN}/$(arch)/skopeo"}
RESOURCES_YAML="res/resources.yaml"
HOOKS_DIR="res/hooks"


REGISTRY=""
USERNAME=""
PASSWORD=""

function detect() {
    local v
    REGISTRY=$(kubectl get productbases.product.alauda.io base -o jsonpath='{.spec.registry.address}' --ignore-not-found)
    v=$(kubectl get secrets -n cpaas-system registry-admin -o jsonpath='{.data.username}' --ignore-not-found)
    if [ "x${v}" != "x" ]; then
        USERNAME=$(echo "${v}" | base64 -d)
    fi
    v=$(kubectl get secrets -n cpaas-system registry-admin -o jsonpath='{.data.password}' --ignore-not-found)
    if [ "x${v}" != "x" ]; then
        PASSWORD=$(echo "${v}" | base64 -d)
    fi
}
detect


function usage() {
    echo "Usage:"
    echo "bash setup.sh [Options]"
    echo "Options:"
    echo "--registry   set registry address, the detected values from the current environment is: ${REGISTRY}"
    echo "--username   set registry username, the detected values from the current environment is: ${USERNAME}"
    echo "--password   set registry password, the default value will be detected from the current environment"
}

function upload_artifacts() {
    while read -r it;
    do
        if [ "${it}" == "" ] || [ "${it:0:1}" == '#' ]; then
            continue
        fi
        echo "uploading ${REGISTRY}/${it} ......"
        "${SKOPEO}" copy --insecure-policy --multi-arch=all --dest-tls-verify=false "--dest-username=${USERNAME}" "--dest-password=${PASSWORD}" "registry:${REGISTRY_DIR}:${it}" "docker://${REGISTRY}/${it}"
    done < "${ARTIFACTS_LIST}"
}

function apply_resources() {
    kubectl apply -f "${RESOURCES_YAML}"
}

function apply_hooks() {
    local hooks
    hooks=$(ls "${HOOKS_DIR}/"*.sh)
    for it in ${hooks};
    do
        bash "${it}"
    done
}

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --registry)
    REGISTRY="$2"
    shift 2
    ;;
    --username)
    USERNAME="$2"
    shift 2
    ;;
    --password)
    PASSWORD="$2"
    shift 2
    ;;
    *)
    echo "unknown key ${key}"
    usage
    exit 1
    ;;
esac
done

upload_artifacts
apply_resources
apply_hooks
