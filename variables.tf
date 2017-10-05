variable "nfs" { 
  type        = "list"
  description =  "IP address of ICP Masters. First master will also be boot master. CE edition only supports single master "
}

variable "ssh_user" {
  description = "Username to ssh into the ICP cluster. This is typically the default user with for the relevant cloud vendor"
  default     = "root"
}

variable "ssh_key" {
  description = "Private key corresponding to the public key that the cloud servers are provisioned with"
  default     = "~/.ssh/id_rsa"
}

variable "cluster_size" {
  description = "Define total clustersize. Workaround for terraform issue #10857."
}

locals {
  icp-ips     = "${var.nfs}"
}
