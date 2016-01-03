#!/bin/sh -eux

# default homedir
HOME_DIR="${HOME_DIR:-/home/vagrant}";

# where the insecure pub key lives
pubkey_url="https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
# create directory for it
mkdir -p $HOME_DIR/.ssh;
# let curl fetch it (it's insecure anyways and will be replaced
curl --insecure --location "$pubkey_url" > $HOME_DIR/.ssh/authorized_keys;

# ensure ownership/permissions
chown -R vagrant $HOME_DIR/.ssh;
chmod -R go-rwsx $HOME_DIR/.ssh;

# speed up sshd by not doing DNS lookups
echo 'UseDNS no' >> /etc/ssh/sshd_config
