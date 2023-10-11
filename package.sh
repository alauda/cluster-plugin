#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


REGISTRY=${REGISTRY:-""}
USERNAME=${USERNAME:-""}
PASSWORD=${PASSWORD:-""}

INPUT_RESOURCES=${INPUT_RESOURCES:-"res/resources.yaml"}
INPUT_ARTIFACTS=${INPUT_ARTIFACTS:-"res/artifacts.txt"}
INPUT_HOOKS=${INPUT_HOOKS:-"res/hooks"}
INPUT_SETUP=${INPUT_SETUP:-"setup.sh"}

TMP_DIR=${TMP_DIR:-"$(mktemp -d)"}
OUTPUT_DIR="${TMP_DIR}/output"
OUTPUT=${OUTPUT:-"plugin.tgz"}

SKOPEO_DOWNLOAD_URL=${SKOPEO_DOWNLOAD_URL:-"https://github.com/alauda/skopeo/releases/download/v1.13.3-alauda.1"}
SKOPEO=${SKOPEO:-""}

KEEP_TMP_DIR=${KEEP_TMP_DIR:-"false"}

function usage() {
    echo "Usage:"
    echo "bash setup.sh [Options]"
    echo "Options:"
    echo "--registry     set the source registry address"
    echo "--username     set the source registry username"
    echo "--password     set the source registry password"
    echo "--output       set the output file path, the default is ${OUTPUT}"
    echo "--resources    set the resources yaml path which containing ModulePlugin, the default is ${INPUT_RESOURCES}"
    echo "--artifacts    set the artifacts path, the default is ${INPUT_ARTIFACTS}"
    echo "--hooks        set the hooks path, the default is ${INPUT_HOOKS}"
    echo "--setup        set the setup path, the default is ${INPUT_SETUP}"
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
    --output)
    OUTPUT="$2"
    shift 2
    ;;
    --resources)
    INPUT_RESOURCES="$2"
    shift 2
    ;;
    --artifacts)
    INPUT_ARTIFACTS="$2"
    shift 2
    ;;
    --hooks)
    INPUT_HOOKS="$2"
    shift 2
    ;;
    *)
    echo "unknown key ${key}"
    usage
    exit 1
    ;;
esac
done

function prepare() {
    echo "Temporary output directory: ${OUTPUT_DIR}"
    mkdir -p "${OUTPUT_DIR}/res/bin/aarch64" "${OUTPUT_DIR}/res/bin/x86_64"
    curl -L -o "${OUTPUT_DIR}/res/bin/aarch64/skopeo" "${SKOPEO_DOWNLOAD_URL}/skopeo.linux.arm64"
    curl -L -o "${OUTPUT_DIR}/res/bin/x86_64/skopeo" "${SKOPEO_DOWNLOAD_URL}/skopeo.linux.amd64"
    chmod +x "${OUTPUT_DIR}/res/bin/aarch64/skopeo" "${OUTPUT_DIR}/res/bin/x86_64/skopeo"
}

function package_artifacts() {
    if [ "${SKOPEO}" == "" ]; then
        if [ "$(uname)" == "Darwin" ]; then
            SKOPEO="${TMP_DIR}/skopeo"
            curl -L -o "${SKOPEO}" "${SKOPEO_DOWNLOAD_URL}/skopeo.darwin.$(arch)"
            chmod +x "${SKOPEO}"
        else
            SKOPEO="${OUTPUT_DIR}/res/bin/$(arch)/skopeo"
        fi
    fi

    mkdir -p "${OUTPUT_DIR}/res/registry"
    while read -r it;
    do
        if [ "${it}" == "" ] || [ "${it:0:1}" == '#' ]; then
            continue
        fi
        echo "packaging ${REGISTRY}/${it} ......"
        "${SKOPEO}" copy --insecure-policy --multi-arch=all --src-tls-verify=false "--src-username=${USERNAME}" "--src-password=${PASSWORD}" "docker://${REGISTRY}/${it}" "registry:${OUTPUT_DIR}/res/registry:${it}"
        echo "$?"
    done < "${INPUT_ARTIFACTS}"

    cp -f "${INPUT_ARTIFACTS}" "${OUTPUT_DIR}/res/artifacts.txt"
}

function package_resources() {
   cp -f "${INPUT_RESOURCES}" "${OUTPUT_DIR}/res/resources.yaml"
}

function package_hooks() {
    cp -rf "${INPUT_HOOKS}" "${OUTPUT_DIR}/res/hooks"
}

function package_setup() {
    cp -f "${INPUT_SETUP}" "${OUTPUT_DIR}/setup.sh"
}

function output() {
   tar -czvf "${OUTPUT}" -C "${OUTPUT_DIR}" .
}

function clean() {
    if [ "${KEEP_TMP_DIR}" == "false" ]; then
        rm -rf "${TMP_DIR}"
    fi
}

prepare
package_resources
package_hooks
package_setup
package_artifacts
output
clean
