#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#

CONFIGURE_JUPYTERLAB_ALLOW_ORIGIN="${CONFIGUREJUPYTERLABALLOWORIGIN:-""}"

sudo_if() {
    COMMAND="$*"
    if [ "$(id -u)" -eq 0 ] && [ "$USERNAME" != "root" ]; then
        su - "$USERNAME" -c "$COMMAND"
    else
        "$COMMAND"
    fi
}

install_user_package() {
    PACKAGE="$1"
    sudo_if "${PYTHON_SRC}" -m pip install --user --upgrade --no-cache-dir "$PACKAGE"
}

add_user_jupyter_config() {
    CONFIG_DIR="/home/$USERNAME/.jupyter"
    CONFIG_FILE="$CONFIG_DIR/jupyter_server_config.py"

    # Make sure the config file exists or create it with proper permissions
    test -d "$CONFIG_DIR" || sudo_if mkdir "$CONFIG_DIR"
    test -f "$CONFIG_FILE" || sudo_if touch "$CONFIG_FILE"

    # Don't write the same config more than once
    grep -q "$1" "$CONFIG_FILE" || echo "$1" >> "$CONFIG_FILE"
}

install_user_package jupyterlab
install_user_package jupyterlab-git

# Configure JupyterLab if needed
if [ -n "${CONFIGURE_JUPYTERLAB_ALLOW_ORIGIN}" ]; then
    add_user_jupyter_config "c.ServerApp.allow_origin = '${CONFIGURE_JUPYTERLAB_ALLOW_ORIGIN}'"
    add_user_jupyter_config "c.NotebookApp.allow_origin = '${CONFIGURE_JUPYTERLAB_ALLOW_ORIGIN}'"
fi