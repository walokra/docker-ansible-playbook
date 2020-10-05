ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION}

LABEL maintainer="Marko Wallin"

ARG ANSIBLE_VERSION="2.9.13"

ENV BUILD_PACKAGES \
  bash \
  curl \
  tar \
  openssh-client \
  sshpass \
  git \
  python3 \
  py3-boto \
  py3-dateutil \
  py3-httplib2 \
  py3-jinja2 \
  py3-paramiko \
  py3-pip \
  py3-yaml \
  ca-certificates

# If installing ansible@testing
#RUN \
#	echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> #/etc/apk/repositories

RUN set -x && \
    \
    echo "==> Adding build-dependencies..."  && \
    apk --update add --virtual build-dependencies \
      g++ \
      build-base \
      libffi-dev \
      openssl-dev \
      python3-dev && \
    \
    echo "==> Upgrading apk and system..."  && \
    apk update && apk upgrade && \
    \
    echo "==> Adding Python runtime..."  && \
    apk add --no-cache ${BUILD_PACKAGES} && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    echo "==> Install pip..."  && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi ;\
    pip3 install --no-cache --upgrade pip && \
    pip3 install --no-cache python-keyczar docker-py && \
    \
    echo "==> Installing Ansible..."  && \
    pip3 install --no-cache ansible==${ANSIBLE_VERSION} && \
    \
    echo "==> Cleaning up..."  && \
    apk del --no-cache --purge build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache && \
    \
    echo "==> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible /ansible && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts
    # ssh-keygen -q -t ed25519 -N '' -f /root/.ssh/id_ed25519 && \
    # mkdir -p ~/.ssh && echo "Host *" > ~/.ssh/config && echo " StrictHostKeyChecking no" >> ~/.ssh/config

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

WORKDIR /ansible/playbooks

ENTRYPOINT ["ansible-playbook"]
