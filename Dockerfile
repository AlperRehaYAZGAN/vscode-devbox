FROM buildpack-deps:22.04-curl

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    sudo \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/

ARG RELEASE_TAG="openvscode-server-v1.87.0"
ARG RELEASE_ORG="gitpod-io"
ARG OPENVSCODE_SERVER_ROOT="/home/.openvscode-server"
ENV OPENVSCODE="${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server"

# Downloading the latest VSC Server release and extracting the release archive
# Rename `openvscode-server` cli tool to `code` for convenience
RUN if [ -z "${RELEASE_TAG}" ]; then \
    echo "The RELEASE_TAG build arg must be set." >&2 && \
    exit 1; \
    fi && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
    arch="x64"; \
    elif [ "${arch}" = "aarch64" ]; then \
    arch="arm64"; \
    elif [ "${arch}" = "armv7l" ]; then \
    arch="armhf"; \
    fi && \
    wget https://github.com/${RELEASE_ORG}/openvscode-server/releases/download/${RELEASE_TAG}/${RELEASE_TAG}-linux-${arch}.tar.gz && \
    tar -xzf ${RELEASE_TAG}-linux-${arch}.tar.gz && \
    mv -f ${RELEASE_TAG}-linux-${arch} ${OPENVSCODE_SERVER_ROOT} && \
    cp ${OPENVSCODE_SERVER_ROOT}/bin/remote-cli/openvscode-server ${OPENVSCODE_SERVER_ROOT}/bin/remote-cli/code && \
    rm -f ${RELEASE_TAG}-linux-${arch}.tar.gz

# Copy ./scripts to /home/workspace/scripts for post-run scripts
RUN mkdir -p /home/workspace/scripts
COPY ./scripts /home/workspace/scripts

# Set the default user and group
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Creating the user and usergroup
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USERNAME -m -s /bin/bash $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN chmod g+rw /home && \
    mkdir -p /home/workspace && \
    chown -R $USERNAME:$USERNAME /home/workspace && \
    chown -R $USERNAME:$USERNAME ${OPENVSCODE_SERVER_ROOT}

USER $USERNAME

# Profile is "bash"
ENV SHELL=/bin/bash

# Set the default directory
WORKDIR /home/workspace/

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/home/workspace \
    EDITOR=code \
    VISUAL=code \
    GIT_EDITOR="code --wait" \
    # set profile bash
    SHELL=/bin/bash \
    OPENVSCODE_SERVER_ROOT=${OPENVSCODE_SERVER_ROOT}

# Default exposed port if none is specified
EXPOSE 3000

# If entrypoint with TOKEN is ensured use "--connection-token" flag. Otherwise, use "--without-connection-token"

# NEW ONE (if TOKEN is set use it, otherwise use without TOKEN)
ENTRYPOINT [ "/bin/sh", "-c", "TOKEN_ARGS=$(if [ -n \"$TOKEN\" ]; then echo \"--connection-token $TOKEN\"; else echo \"--without-connection-token\"; fi) && exec ${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server --host 0.0.0.0 $TOKEN_ARGS" ]

