
# Generate a new key if this is required
resource "tls_private_key" "icpkey" {
  count       = "${var.generate_key ? 1 : 0}"
  algorithm   = "RSA"
  
  provisioner "local-exec" {
    command = "cat > privatekey.pem <<EOL\n${tls_private_key.icpkey.private_key_pem}\nEOL"
  }
}

## Actions that has to be taken on all nodes in the cluster
resource "null_resource" "icp-cluster" {

  count = "${var.cluster_size}"
  
  connection {
      host = "${element(local.icp-ips, count.index)}"
      user = "${var.ssh_user}"
      private_key = "${file(var.ssh_key)}"
  }
   
  # Validate we can do passwordless sudo in case we are not root
  provisioner "remote-exec" {
    inline = [
      "sudo -n echo This will fail unless we have passwordless sudo access"
    ]
  }

  provisioner "file" {
      content = "${var.generate_key ? tls_private_key.icpkey.public_key_openssh : file(var.icp_pub_keyfile)}"
      destination = "/tmp/icpkey"
  
  }
  
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/icp-common-scripts"
    ]
  }
  provisioner "file" {
    source      = "${path.module}/scripts/common/"
    destination = "/tmp/icp-common-scripts"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "cat /tmp/icpkey >> ~/.ssh/authorized_keys",
      "chmod a+x /tmp/icp-common-scripts/*",
      "/tmp/icp-common-scripts/prereqs.sh",
      "/tmp/icp-common-scripts/version-specific.sh ${var.icp-version}",
      "/tmp/icp-common-scripts/docker-user.sh"
    ]
  }
}


## Actions that needs to be taken on boot master only
resource "null_resource" "icp-boot" {

  depends_on = ["null_resource.icp-cluster"]

  # The first master is always the boot master where we run provisioning jobs from
  connection {
    host = "${element(var.nfs, 0)}"
    user = "${var.ssh_user}"
    private_key = "${file(var.ssh_key)}"
  } 

  
  # If this is enterprise edition we'll need to copy the image file over and load it in local repository
  // We'll need to find another workaround while tf does not support count for this
  provisioner "file" {
      # count = "${var.enterprise-edition ? 1 : 0}"
      source = "${var.enterprise-edition ? var.image_file : "/dev/null" }"
      destination = "/tmp/${basename(var.image_file)}"
  }
  

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/icp-bootmaster-scripts"
    ]
  }
  provisioner "file" {
    source      = "${path.module}/scripts/boot-master/"
    destination = "/tmp/icp-bootmaster-scripts"
  }
  
  # Copy the provided or generated private key
  provisioner "file" {
      content = "${var.generate_key ? tls_private_key.icpkey.private_key_pem : file(var.icp_priv_keyfile)}"
      destination = "/opt/ibm/cluster/ssh_key"
  }
  
  provisioner "file" {
    content = "${join(",", var.nfs)}"
    destination = "/opt/ibm/cluster/masterlist.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "/tmp/icp-bootmaster-scripts/generate_hostsfiles.sh",
      "/tmp/icp-bootmaster-scripts/start_install.sh ${var.icp-version}"
      
    ]
  }
  
  # Check if var.ssh_user is root. If not add ansible_become lines 
  
  provisioner "remote-exec" {
    inline = [
      
    ]
  }
}

