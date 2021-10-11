/**

    $ OPENLABS/CFG/VDB, v.1.1 2021/10/11 12:36 Exp @di $

    // base
    variable "cfg_project" { default = "vdb" }

    variable "cfg_project_user" { default = "vdb" }
    variable "cfg_project_password" { default = "zalupa123123" }

    variable "cfg_image_name" { default = "debian-10" }
    variable "cfg_image_url" { default = "https://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2" }

    variable "cfg_router_ams" { default = "router-vdb-ams" }
    variable "cfg_router_ldn" { default = "router-vdb-ldn" }

    variable "cfg_net_ams_master" { default = "vdb-master" }
    variable "cfg_subnet_ams_master" { default = "172.19.16.0/24" }

    variable "cfg_net_ams_slave" { default = "vdb-slave" }
    variable "cfg_subnet_ams_slave" { default = "172.19.17.0/24" }

    variable "cfg_net_ldn_delay" { default = "vdb-delay" }
    variable "cfg_subnet_ldn_delay" { default = "172.20.16.0/24" }

    variable "cfg_dns" { default = "172.21.17.17" }

    variable "cfg_region" { default = "RegionOne" }

    // flavor
    variable "cfg_flavor_vdb_master" { default = "vdb-master" }
    variable "cfg_flavor_vdb_slave" { default = "vdb-slave" }
    variable "cfg_flavor_vdb_delay" { default = "vdb-delay" }
    variable "cfg_flavor_vdb_sysbench" { default = "vdb-sysbench" }

    // volume
    variable "cfg_volume_type_ams_ssd_5" { default = "ams-ssd-rack-5" }
    variable "cfg_volume_type_ams_ssd_6" { default = "ams-ssd-rack-6" }
    variable "cfg_volume_type_ldn_ssd_17" { default = "ldn-ssd-rack-17" }
    variable "cfg_volume_type_ldn_ssd_18" { default = "ldn-ssd-rack-18" }
    
**/

variable "api_url" {}
variable "api_admin_password" {}

variable "cfg_mgmt_user" {}
variable "cfg_mgmt_ip" {}
variable "cfg_mgmt_private_key" {}

variable "cfg_project" {}

variable "cfg_project_user" {}
variable "cfg_project_password" {}

variable "cfg_image_name" {}
variable "cfg_image_url" {}

variable "cfg_router_ams" {}
variable "cfg_router_ldn" {}

variable "cfg_net_ams_master" {}
variable "cfg_subnet_ams_master" {}

variable "cfg_net_ams_slave" {}
variable "cfg_subnet_ams_slave" {}

variable "cfg_net_ldn_delay" {}
variable "cfg_subnet_ldn_delay" {}

variable "cfg_dns" {}

variable "cfg_region" {}

// flavor
variable "cfg_flavor_vdb_master" {}
variable "cfg_flavor_vdb_slave" {}
variable "cfg_flavor_vdb_delay" {}
variable "cfg_flavor_vdb_sysbench" {}

// compute
variable "cfg_compute_ams_kvm0_hostname" {}
variable "cfg_compute_ams_kvm1_hostname" {}
variable "cfg_compute_ams_kvm2_hostname" {}
variable "cfg_compute_ldn_kvm3_hostname" {}
variable "cfg_compute_ldn_kvm4_hostname" {}
variable "cfg_compute_ldn_kvm5_hostname" {}

// volume
variable "cfg_volume_type_ams_ssd_5" {}
variable "cfg_volume_type_ams_ssd_6" {}
variable "cfg_volume_type_ldn_ssd_17" {}
variable "cfg_volume_type_ldn_ssd_18" {}

variable "storage_backend_name_ams_rack_5" {}
variable "storage_backend_name_ams_rack_6" {}
variable "storage_backend_name_ldn_rack_17" {}
variable "storage_backend_name_ldn_rack_18" {}


resource "null_resource" "cfg" {
  provisioner "remote-exec" {
    inline = [
      "export OS_PROJECT_DOMAIN_ID=default",
      "export OS_USER_DOMAIN_ID=default",
      "export OS_PROJECT_DOMAIN_NAME=default",
      "export OS_USER_DOMAIN_NAME=default",
      "export OS_PROJECT_NAME=admin",
      "export OS_USERNAME=admin",
      "export OS_PASSWORD=${var.api_admin_password}",
      "export OS_AUTH_URL=${var.api_url}",
      "export OS_IDENTITY_API_VERSION=3",
      "export OS_IMAGE_API_VERSION=2",
      "export OS_VOLUME_API_VERSION=3",

      "openstack project create  ${var.cfg_project} --domain default",
      "openstack user create --project ${var.cfg_project}  --password ${var.cfg_project_password}  ${var.cfg_project_user}",
      "openstack role add --project ${var.cfg_project} --user ${var.cfg_project_user} --user-domain default member",
      "openstack role add --project ${var.cfg_project} --user ${var.cfg_project_user} --user-domain default admin",

      "openstack quota set --instances 100 ${var.cfg_project}",
      "openstack quota set --volumes 100 ${var.cfg_project}",
      "openstack quota set --cores 100 ${var.cfg_project}",

      "wget -O ${var.cfg_image_name} ${var.cfg_image_url}",
      "openstack image create ${var.cfg_image_name} --public --disk-format qcow2 --container-format bare --file ${var.cfg_image_name}",

      "openstack aggregate create --zone AMS1 ams-rack-5",
      "openstack aggregate create --zone AMS1 ams-rack-6",
      "openstack aggregate create --zone LDN1 ldn-rack-17",

      "openstack aggregate add host ams-rack-5 ${var.cfg_compute_ams_kvm0_hostname}",
      "openstack aggregate add host ams-rack-6 ${var.cfg_compute_ams_kvm1_hostname}",
      "openstack aggregate add host ams-rack-6 ${var.cfg_compute_ams_kvm2_hostname}",
      "openstack aggregate add host ldn-rack-17 ${var.cfg_compute_ldn_kvm3_hostname}",
      "openstack aggregate add host ldn-rack-17 ${var.cfg_compute_ldn_kvm4_hostname}",
      "openstack aggregate add host ldn-rack-17 ${var.cfg_compute_ldn_kvm5_hostname}",

      "openstack aggregate set --property vdb-master=true ams-rack-5",
      "openstack aggregate set --property vdb-slave=true ams-rack-6",

      "openstack flavor create --property \"aggregate_instance_extra_specs:vdb-master\"=\"true\" --vcpus 2 --ram 2048 --disk 15 ${var.cfg_flavor_vdb_master}",
      "openstack flavor create --property \"aggregate_instance_extra_specs:vdb-slave\"=\"true\" --vcpus 2 --ram 2048 --disk 15 ${var.cfg_flavor_vdb_slave}",
      "openstack flavor create --vcpus 2 --ram 2048 --disk 15 ${var.cfg_flavor_vdb_delay}",
      "openstack flavor create --vcpus 2 --ram 2048 --disk 15 ${var.cfg_flavor_vdb_sysbench}",

      "openstack volume type create ${var.cfg_volume_type_ams_ssd_5}",
      "openstack volume type create ${var.cfg_volume_type_ams_ssd_6}",
      "openstack volume type create ${var.cfg_volume_type_ldn_ssd_17}",
      "openstack volume type create ${var.cfg_volume_type_ldn_ssd_18}",

      "openstack volume type set ${var.cfg_volume_type_ams_ssd_5} --property volume_backend_name=${var.storage_backend_name_ams_rack_5}",
      "openstack volume type set ${var.cfg_volume_type_ams_ssd_6} --property volume_backend_name=${var.storage_backend_name_ams_rack_6}",
      "openstack volume type set ${var.cfg_volume_type_ldn_ssd_17} --property volume_backend_name=${var.storage_backend_name_ldn_rack_17}",
      "openstack volume type set ${var.cfg_volume_type_ldn_ssd_18} --property volume_backend_name=${var.storage_backend_name_ldn_rack_18}",

      // ams-gw-ext (ext-net need request noc)
      "openstack network create ams-gw-ext --external --availability-zone-hint AMS1 --provider-physical-network physnet1 --provider-network-type vlan --provider-segment 2215",
      "openstack subnet create ams-gw-ext --network ams-gw-ext --subnet-range 10.22.15.0/24 --allocation-pool start=10.22.15.11,end=10.22.15.254 --no-dhcp --gateway none",

      // ldn-gw-ext (ext-net need request noc)
      "openstack network create ldn-gw-ext --external --availability-zone-hint LDN1 --provider-physical-network physnet1 --provider-network-type vlan --provider-segment 2315",
      "openstack subnet create ldn-gw-ext --network ldn-gw-ext --subnet-range 10.23.15.0/24 --allocation-pool start=10.23.15.11,end=10.23.15.254 --no-dhcp --gateway none",

      // ams-router (ext-ip need request noc)
      "openstack router create --availability-zone AMS1 --ha ${var.cfg_router_ams}",
      "openstack router set --fixed-ip subnet=ams-gw-ext,ip-address=10.22.15.12 --disable-snat --external-gateway ams-gw-ext ${var.cfg_router_ams}",
      "openstack router set --route destination=0.0.0.0/0,gateway=10.22.15.1 ${var.cfg_router_ams}",

      // ams-router (ext-ip need request noc)
      "openstack router create --availability-zone LDN1 --ha ${var.cfg_router_ldn}",
      "openstack router set --fixed-ip subnet=ldn-gw-ext,ip-address=10.23.15.12 --disable-snat --external-gateway ldn-gw-ext ${var.cfg_router_ldn}",
      "openstack router set --route destination=0.0.0.0/0,gateway=10.23.15.1 ${var.cfg_router_ldn}",

      // network (master,slave,delay)
      "openstack network create --availability-zone-hint AMS1 ${var.cfg_net_ams_master}",
      "openstack network create --availability-zone-hint AMS1 ${var.cfg_net_ams_slave}",
      "openstack network create --availability-zone-hint LDN1 ${var.cfg_net_ldn_delay}",

      "openstack subnet create --network ${var.cfg_net_ams_master} --subnet-range ${var.cfg_subnet_ams_master} --dns-nameserver ${var.cfg_dns} ${var.cfg_net_ams_master}",
      "openstack subnet create --network ${var.cfg_net_ams_slave} --subnet-range ${var.cfg_subnet_ams_slave} --dns-nameserver ${var.cfg_dns} ${var.cfg_net_ams_slave}",
      "openstack subnet create --network ${var.cfg_net_ldn_delay} --subnet-range ${var.cfg_subnet_ldn_delay} --dns-nameserver ${var.cfg_dns} ${var.cfg_net_ldn_delay}",

      "openstack router add subnet ${var.cfg_router_ams} ${var.cfg_net_ams_master}",
      "openstack router add subnet ${var.cfg_router_ams} ${var.cfg_net_ams_slave}",
      "openstack router add subnet ${var.cfg_router_ldn} ${var.cfg_net_ldn_delay}"
    ]

    connection {
      type     = "ssh"
      user     = var.cfg_mgmt_user
      private_key = file(var.cfg_mgmt_private_key)
      host = var.cfg_mgmt_ip
    }
  }
}

output "api_url" { value = var.api_url }
output "api_user" { value = var.cfg_project_user }
output "api_password" { value = var.cfg_project_password }
output "tenant_name" { value = var.cfg_project }
output "region" { value = var.cfg_region }
