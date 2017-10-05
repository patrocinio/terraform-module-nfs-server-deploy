# Terraform ICP Provision Module
This terraform module can be used to deploy IBM Cloud Private on any supported infrastructure vendor.
Currently tested with Ubuntu 16.06 on SoftLayer VMs, deploying ICP 1.2.0 and 2.1.0-beta-1 Community Editions.

### Pre-requisites

If the default SSH user is not the root user, the default user must have password-less sudo access.


## Inputs

| variable  |  default  | required |  description    |
|-----------|-----------|---------|--------|
|  icp-version   |      |  Yes  |   Version of ICP to provision. Format Can be tag, repo:tag or org/repo:tag. <br>For example `1.2.0`, `1.2.0-ee`, `icp-inception:2.1.0-beta-2`.<br>`ibmcom` is default org, `cfc-installer` is default repo  | 
|  nfs   |      |  Yes  |   IP address of NFS Server. 
|  cluster_size   |      |  Yes  |   Define total clustersize. Workaround for terraform issue #10857.                | 
|  icp_configuration   |   {}   |  No  |   Configuration items for ICP installation.                | 
|  enterprise-edition   |   False   |  No  |   Whether to provision enterprise edition (EE) or community edition (CE). EE requires image files to be provided                | 
|  ssh_key   |   ~/.ssh/id_rsa   |  No  |   Private key corresponding to the public key that the cloud servers are provisioned with                | 
|  icppassword   |   admin   |  No  |   Password of initial admin user. Default: Admin                | 
|  ssh_user   |   root   |  No  |   Username to ssh into the ICP cluster. This is typically the default user with for the relevant cloud vendor                | 
|  icp_pub_keyfile   |   /dev/null   |  No  |   Public ssh key for ICP Boot master to connect to ICP Cluster. Only use when generate_key = false                | 
|  generate_key   |   False   |  No  |   Whether to generate a new ssh key for use by ICP Boot Master to communicate with other nodes                | 
|  image_file   |   /dev/null   |  No  |   Filename of image. Only required for enterprise edition                | 
|  icp_priv_keyfile   |   /dev/null   |  No  |   Private ssh key for ICP Boot master to connect to ICP Cluster. Only use when generate_key = false                | 
|  icp_config_file   |   /dev/null   |  No  |   Yaml configuration file for ICP installation                | 



## Usage example

```hcl
module "icpprovision" {
    source = "github.com/ibm-cloud-architecture/terraform-module-icp-deploy"
    
    nfs = ["${softlayer_virtual_guest.nfs.ipv4_address}"]
    
    enterprise-edition = false
    #icp-version = "2.1.0-beta-1"
    icp-version = "1.2.0"

    /* Workaround for terraform issue #10857
     When this is fixed, we can work this out autmatically */
    cluster_size  = "${var.master["nodes"] + var.worker["nodes"] + var.proxy["nodes"]}"

    icp_configuration = {
      "network_cidr"              = "192.168.0.0/16"
      "service_cluster_ip_range"  = "172.16.0.1/24"
    }

    generate_key = true
    
    ssh_user  = "ubuntu"
    ssh_key   = "~/.ssh/id_rsa"
    
} 
```





