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
cp /etc/pve/priv/ceph.client.rgw.$(hostname).keyring /etc/ceph/
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

## RADOS Gateway Reverse Proxy setup
RADOS Gateway connections is fronted by a high-availability reverse proxies set up on the internal `s3-cafe.acmuic.org` DNS. These reverse proxy hypervisors were setup using a self-signed certificate with a SAN reflecting the internal DNS. The HAProxy is then configured with
```
frontend rgw_https
        bind <s3-cafe.acmuic.org-IP> ssl crt /etc/haproxy/certs/rgw-proxy.pem
        default_backend rgw_backend

backend rgw_backend
        option forwardfor
        balance roundrobin
        option httpchk HEAD / HTTP/1.0
        server rgw-node-01 <boba-ceph-IP>:7480 check inter 2s
        server rgw-node-02 <matcha-ceph-IP>:7480 check inter 2s
        server rgw-node-03 <chai-ceph-IP>:7480 check inter 2s
        server rgw-node-04 <coffee-ceph-IP>:7480 check inter 2s
```

Of course, the `<s3-cafe.acmuic.org-IP>` is a virtual (floating) IP in which the proxies can fail-over with these `keepalived` configs
```
vrrp_instance VI_S3 {
    state <MASTER/BACKUP>
    interface eth0
    virtual_router_id 51
    priority <110/100>
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass <YAMETE_KUDASAI>
    }
    virtual_ipaddress {
        <s3-cafe.acmuic.org-IP>/24
    }
}
```

**Note:** As the time of writing, the virtual IP must be assigned from the same subnet as the proxy's real interface. Placing it in a different VLAN will cause ARP resolution failures.

## Users and buckets
<!-- TODO -->