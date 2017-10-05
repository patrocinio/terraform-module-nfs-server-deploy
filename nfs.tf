
## Actions that needs to be taken on boot master only
resource "null_resource" "nfs" {

  # The first master is always the boot master where we run provisioning jobs from
  connection {
    host = "${element(var.nfs, 0)}"
    user = "${var.ssh_user}"
    private_key = "${file(var.ssh_key)}"
  } 


  provisioner "remote-exec" {
    inline = [
      "sudo apt install -y nfs-kernel-server"
    ]
  }

}

