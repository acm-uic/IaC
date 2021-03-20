data "vsphere_datacenter" "datacenter" {
  name = "ACM"
}

data "vsphere_resource_pool" "cluster" {
  name          = "bharat.acm.cs/Resources"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_host" "host" {
  name          = "bharat.acm.cs"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = "TrueNASDatastore"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

resource "vsphere_content_library" "library" {
  name            = "General Images"
  storage_backing = data.vsphere_datastore.datastore.id
  description     = "General VM Images hosted on truenas.acm.cs"
}

resource "vsphere_content_library_item" "ubuntu2004_cloudimg" {
  name        = "Ubuntu-20.04-server-cloudimg-amd64"
  description = "Ubuntu 20.04 - focal-server-cloudimg-amd64 OVA"
  library_id  = vsphere_content_library.library.id
  file_url    = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova"
}

resource "vsphere_virtual_machine" "vm_ova" {
  name                       = "azureLinuxWorker"
  resource_pool_id           = data.vsphere_resource_pool.cluster.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  datacenter_id              = data.vsphere_datacenter.datacenter.id
  ovf_deploy {
    remote_ovf_url       = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova"
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "DHCP"
    ovf_network_map = {
      "ESX-port-1" = data.vsphere_network.network.id
    }
  }
  vapp {
    properties = {
      "guestinfo.tf.internal.id" = "42"
    }
  }

  #  network_interface {
  #    network_id = data.vsphere_network.network.id
  #  }
  #
  #  clone {
  #    template_uuid = vsphere_content_library_item.ubuntu2004_cloudimg.id
  #    customize {
  #      linux_options {
  #        host_name = "azureLinuxWorker"
  #        domain    = "acm.cs"
  #      }
  #    }
  #  }
}

output "test_datacenter" {
  value = data.vsphere_datacenter.datacenter.id
}

output "test_resource_pool" {
  value = data.vsphere_resource_pool.cluster.id
}

output "test_host" {
  value = data.vsphere_host.host.id
}

output "test_datastore" {
  value = data.vsphere_datastore.datastore.id
}

output "test_network" {
  value = data.vsphere_network.network.id
}
