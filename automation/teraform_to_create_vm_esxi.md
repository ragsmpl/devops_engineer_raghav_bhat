<> tree test
test
├── terraform.tfvars
├── test.tf
└── variables.tf
terraform.tfvars contains the credentials for the vsphere login
test.tf contains most of the infrastructure definition (this is just a single VM in my example, but could be much larger)
variables.tf contains the variables which can be passed into the test.tf file for processing.
Here is how my files looked like in the end:

<> cat test/test.tf
## Configure the vSphere Provider
provider "vsphere" {
    vsphere_server = "${var.vsphere_server}"
    user = "${var.vsphere_user}"
    password = "${var.vsphere_password}"
    allow_unverified_ssl = true
}

## Build VM
data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {}

data "vsphere_network" "mgmt_lan" {
  name          = "VM_VLAN1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "test2" {
  name             = "test2"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus   = 1
  memory     = 2048
  wait_for_guest_net_timeout = 0
  guest_id = "centos7_64Guest"
  nested_hv_enabled =true
  network_interface {
   network_id     = "${data.vsphere_network.mgmt_lan.id}"
   adapter_type   = "vmxnet3"
  }

  disk {
   size             = 16
   name             = "test2.vmdk"
   eagerly_scrub    = false
   thin_provisioned = true
  }
}
And here is the second one:

<> cat test/variables.tf
variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_password" {}
And here is the last one:

<> cat test/terraform.tfvars
vsphere_server = "192.168.1.109"
vsphere_user = "root"
vsphere_password = "password"
Now we are ready to create our infrastructure.

terraform init
terraform plan
terraform apply
