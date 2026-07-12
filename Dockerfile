FROM node:24-bookworm-slim

ARG DEVSPACE_VERSION=1.0.4

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        file \
        findutils \
        git \
        gosu \
        jq \
        less \
        openssh-client \
        python3 \
        ripgrep \
        tar \
        unzip \
    && npm install --global "@waishnav/devspace@${DEVSPACE_VERSION}" \
    && npm cache clean --force \
    && apt-get purge -y --auto-remove build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash --uid 10001 devspace \
    && mkdir -p /workspace /usr/local/share/devspace/defaults \
    && chown -R devspace:devspace /workspace

COPY --chown=devspace:devspace defaults/ /usr/local/share/devspace/defaults/
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENV HOME=/home/devspace \
    HOST=0.0.0.0 \
    PORT=7676 \
    DEVSPACE_CONFIG_DIR=/home/devspace/.devspace \
    DEVSPACE_STATE_DIR=/home/devspace/.devspace/state \
    DEVSPACE_WORKTREE_ROOT=/home/devspace/.devspace/worktrees \
    DEVSPACE_ALLOWED_ROOTS=/workspace \
    DEVSPACE_TOOL_MODE=full \
    DEVSPACE_WIDGETS=changes

WORKDIR /workspace
VOLUME ["/home/devspace/.devspace"]
EXPOSE 7676

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["devspace", "serve"]
