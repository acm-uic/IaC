# RADOS Gateway setup on Maid Cafe

This here is just a documentation of how the RADOS Gateway was setup on Maid-Cafe cluster.

Note this setup was done as `root`

## Prerequisites
Install the RADOS Gateway capabilities on each node
```
apt install -y radosgw
```

## Bootstrapping
On each node, generate its own key and share them throughout the cluster with
```
ceph auth get-or-create client.rgw.$(hostname) \
	osd 'allow rwx' \
	mon 'allow rw' \
	mgr 'allow rw'\
	-o /etc/pve/priv/ceph.client.rgw.$(hostname).keyring
```

Make a local copy of the key 
```
mv /etc/pve/priv/ceph.client.rgw.$(hostname).keyring /etc/ceph/
```

Edit `/etc/ceph/ceph.conf -> /etc/pve/ceph.conf` to point to local key
```
[client.rgw.<node-name>]
        host = <node-name>
        keyring = /etc/ceph/ceph.client.rgw.<node-name>.keyring
        log_file = /var/log/ceph/client.rgw.<node-name>.log
        rgw_frontends = "beast port=7480"
```

Once done, start the systemd service
```
systemctl enable --now ceph-radosgw@rgw.$(hostname)
```

## Users and buckets
<!-- TODO -->