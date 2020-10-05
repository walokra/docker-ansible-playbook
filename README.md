# Ansible Playbook Docker Image

Docker Image of Ansible for executing ansible-playbook command against an externally mounted set of Ansible playbooks. Based on [philm/ansible_playbook](https://github.com/philm/ansible_playbook)

## Build

```shell
docker build -t walokra/ansible-playbook .
```

### Test

```shell
$ docker run --name ansible-playbook --rm walokra/ansible-playbook --version

ansible-playbook 2.9.6
  config file = None
  configured module search path = ['/ansible/library']
  python version = 3.8.3 (default, May 15 2020, 01:53:50) [GCC 9.3.0]
```

## Running Ansible Playbook

```shell
docker run --rm -it -v PATH_TO_LOCAL_PLAYBOOKS_DIR:/ansible/playbooks walokra/ansible-playbook PLAYBOOK_FILE
```

For example, assuming your project's structure follows [best practices](http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout), the command to run ansible-playbook from the top-level directory would look like:

```shell
docker run --rm -it -v $(pwd):/ansible/playbooks walokra/ansible-playbook site.yml
```

Ansible playbook variables can simply be added after the playbook name.

### Ansible Helper wrapper

Shell script named ansible_helper that wraps a Docker image containing Ansible:

```shell
docker run --rm -it \
  -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
  -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
  -v $(pwd):/ansible/playbooks \
  -v /var/log/ansible/ansible.log \
  walokra/ansible-playbook "$@"
```

Point the above script to any inventory file so that we can execute any Ansible command on any host, e.g.

```shell
./ansible_helper playbooks/site.yml -i inventory -e 'url=http://google.com'
```

## SSH Keys

If Ansible is interacting with external machines, you'll need to mount an SSH key pair for the duration of the play:

```shell
docker run --rm -it \
    -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
    -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
    -v $(pwd):/ansible/playbooks \
    walokra/ansible-playbook site.yml
```

## Ansible Vault

If you've encrypted any data using [Ansible Vault](http://docs.ansible.com/ansible/playbooks_vault.html), you can decrypt during a play by either passing **--ask-vault-pass** after the playbook name, or pointing to a password file. For the latter, you can mount an external file:

```shell
docker run --rm -it -v $(pwd):/ansible/playbooks \
    -v ~/.vault_pass.txt:/root/.vault_pass.txt \
    walokra/ansible-playbook \
    site.yml --vault-password-file /root/.vault_pass.txt
```

Note: the Ansible Vault executable is embedded in this image. To use it, specify a different entrypoint:

```shell
docker run --rm -it -v $(pwd):/ansible/playbooks --entrypoint ansible-vault \
  walokra/ansible-playbook encrypt FILENAME
```

## Make

```shell
$ make
build                          build container
build-no-cache                 build container without cache
build-ver                      build specific ansible version: make build-ver ALPINE_VERSION="3.9" ANSIBLE_VERSION="2.7.6"
clean                          remove images
help                           this help
history                        show docker history for container
inspect                        inspect container properties - pretty: 'make inspect | jq .' requires jq
logs                           show docker logs for container (ONLY possible while container is running)
run                            run container
test                           test container with builtin tests
```
