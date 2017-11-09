# Ansible Playbook Docker Image

Docker Image of Ansible for executing ansible-playbook command against an externally mounted set of Ansible playbooks. Based on [philm/ansible_playbook](https://github.com/philm/ansible_playbook)

## Build

```
docker build -t walokra/ansible-playbook .
```

## Running Ansible Playbook

```
docker run --rm -it -v PATH_TO_LOCAL_PLAYBOOKS_DIR:/ansible/playbooks walokra/ansible-playbook PLAYBOOK_FILE
```

For example, assuming your project's structure follows [best practices](http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout), the command to run ansible-playbook from the top-level directory would look like:

```
docker run --rm -it -v $(pwd):/ansible/playbooks walokra/ansible-playbook site.yml
```

Ansible playbook variables can simply be added after the playbook name.

### Ansible Helper wrapper

Shell script named ansible_helper that wraps a Docker image containing Ansible:

```
docker run --rm -it \
  -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
  -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
  -v $(pwd):/ansible_playbooks \
  -v /var/log/ansible/ansible.log \
  walokra/ansible-playbook "$@"
```

Point the above script to any inventory file so that we can execute any Ansible command on any host, e.g.

```
./ansible_helper play playbooks/create_user.yml -i inventory/staging -e 'some_var=some_value'
```

## SSH Keys

If Ansible is interacting with external machines, you'll need to mount an SSH key pair for the duration of the play:

```
docker run --rm -it \
    -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
    -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
    -v $(pwd):/ansible/playbooks \
    walokra/ansible-playbook site.yml
```

## Ansible Vault

If you've encrypted any data using [Ansible Vault](http://docs.ansible.com/ansible/playbooks_vault.html), you can decrypt during a play by either passing **--ask-vault-pass** after the playbook name, or pointing to a password file. For the latter, you can mount an external file:

```
docker run --rm -it -v $(pwd):/ansible/playbooks \
    -v ~/.vault_pass.txt:/root/.vault_pass.txt \
    walokra/ansible-playbook \
    site.yml --vault-password-file /root/.vault_pass.txt
```                    

Note: the Ansible Vault executable is embedded in this image. To use it, specify a different entrypoint:

```
docker run --rm -it -v $(pwd):/ansible/playbooks --entrypoint ansible-vault \
  walokra/ansible-playbook encrypt FILENAME
```
