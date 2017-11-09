FROM alpine:3.6

ENV ANSIBLE_VERSION 2.3.0.0

ENV BUILD_PACKAGES \
  bash \
  curl \
  tar \
  openssh-client \
  python \
  py-boto \
  py-dateutil \
  py-httplib2 \
  py-jinja2 \
  py-paramiko \
  py-pip \
  py-setuptools \
  py-yaml \
  ca-certificates

RUN apk --update add --virtual build-dependencies \
  gcc \
  musl-dev \
  libffi-dev \
  openssl-dev \
  python-dev

# If installing ansible@testing
#RUN \
#	echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> #/etc/apk/repositories

RUN set -x && \
    apk update && apk upgrade && \
    apk add --no-cache ${BUILD_PACKAGES} && \
    pip install --upgrade pip && \
    pip install python-keyczar docker-py && \
    # Cleaning up
    apk del build-dependencies && \
  	rm -rf /var/cache/apk/*

RUN \
  mkdir -p /etc/ansible/ /opt/ansible

RUN \
  echo "[local]" >> /etc/ansible/hosts && \
  echo "localhost" >> /etc/ansible/hosts

RUN \
  curl -fsSL https://releases.ansible.com/ansible/ansible-${ANSIBLE_VERSION}.tar.gz -o ansible.tar.gz && \
  tar -xzf ansible.tar.gz -C /opt/ansible --strip-components 1 && \
  rm -fr ansible.tar.gz /opt/ansible/docs /opt/ansible/examples /opt/ansible/packaging

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /opt/ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /opt/ansible/lib
ENV PATH /opt/ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /opt/ansible/library

WORKDIR /opt/ansible/playbooks

ENTRYPOINT ["ansible-playbook"]
