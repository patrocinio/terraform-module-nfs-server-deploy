# Terraform ICP Provision Module
This terraform module can be used to deploy IBM Cloud Private on any supported infrastructure vendor.
Currently tested with Ubuntu 16.06 on SoftLayer VMs, deploying ICP 1.2.0 and 2.1.0-beta-1 Community Editions.

### Pre-requisites

If the default SSH user is not the root user, the default user must have password-less sudo access.


## Inputs

| variable  |  default  | required |  description    |
|-----------|-----------|---------|--------|
|  icp-version   |      |  Yes  |   Version of ICP to provision. Format Can be tag, repo:tag or org/repo:tag. <br>For example `1.2.0`, `1.2.0-ee`, `icp-inception:2.1.0-beta-2`.<br>`ibmcom` is default org, `cfc-installer` is default repo  | 
|  icp-master   |      |  Yes  |   IP address of ICP Masters. First master will also be boot master. CE edition only supports single master                 | 
|  cluster_size   |      |  Yes  |   Define total clustersize. Workaround for terraform issue #10857.                | 
|  icp_configuration   |   {}   |  No  |   Configuration items for ICP installation.                | 
|  enterprise-edition   |   False   |  No  |   Whether to provision enterprise edition (EE) or community edition (CE). EE requires image files to be provided                | 
|  ssh_key   |   ~/.ssh/id_rsa   |  No  |   Private key corresponding to the public key that the cloud servers are provisioned with                | 
|  icpuser   |   admin   |  No  |   Username of initial admin user. Default: Admin                | 
|  config_strategy   |   merge   |  No  |   Strategy for original config.yaml shipped with ICP. Default is merge, everything else means override                | 
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
    
    icp-master = ["${softlayer_virtual_guest.icpmaster.ipv4_address}"]
    
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

### ICP Configuration 
Configuration file is generated from items in the following order

1. config.yaml shipped with ICP (if config_strategy = merge, else blank)
2. config.yaml specified in `icp_config_file`
3. key: value items specified in `icp_configuration`

Details on configuration items on ICP KnowledgeCenter
* [ICP 1.2.0](https://www.ibm.com/support/knowledgecenter/SSBS6K_1.2.0/installing/config_yaml.html)
* [ICP 2.1.0-Beta](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/config_yaml.html)


### Scaling
The module supports automatic scaling of worker nodes.
To scale simply add more nodes in the root resource supplying the `icp-worker` variable.
You can see working examples for softlayer [in the icp-softlayer](https://github.com/ibm-cloud-architecture/terraform-icp-softlayer) repository

Please note, because of how terraform handles module dependencies and triggers, it is currently necessary to retrigger the scaling resource **after scaling down** nodes.
If you don't do this ICP will continue to report inactive nodes until the next scaling event.
To manually trigger the removal of deleted node, run these commands:

1. `terraform taint --module icpprovision null_resource.icp-worker-scaler`
2. `terraform apply`



