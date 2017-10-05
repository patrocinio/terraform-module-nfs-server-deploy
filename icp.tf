
# Generate a new key if this is required
resource "tls_private_key" "icpkey" {
  count       = "${var.generate_key ? 1 : 0}"
  algorithm   = "RSA"
  
  provisioner "local-exec" {
    command = "cat > privatekey.pem <<EOL\n${tls_private_key.icpkey.private_key_pem}\nEOL"
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

  
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/icp-bootmaster-scripts"
    ]
  }
  provisioner "file" {
    source      = "${path.module}/scripts/boot-master/"
    destination = "/tmp/icp-bootmaster-scripts"
  }
  
  provisioner "file" {
    content = "${join(",", var.nfs)}"
    destination = "/opt/ibm/cluster/masterlist.txt"
  }

  # Check if var.ssh_user is root. If not add ansible_become lines 
  
  provisioner "remote-exec" {
    inline = [
      
    ]
  }
}

