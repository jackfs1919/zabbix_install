data "vkcs_compute_flavor" "compute" {
  name = "Standard-2-8-50"
}

data "vkcs_images_image" "compute" {
  name = "Debian11.4.202208"
}


resource "vkcs_compute_instance" "compute" {
  name                    = "user31-exam"
  flavor_id               = data.vkcs_compute_flavor.compute.id
  security_groups         = ["default", "all"]
  availability_zone       = "GZ1"
  key_pair = vkcs_compute_keypair.test-keypair.name

  block_device {
    uuid                  = data.vkcs_images_image.compute.id
    source_type           = "image"
    destination_type      = "volume"
    volume_type           = "ceph-ssd"
    volume_size           = 50
    boot_index            = 0
    delete_on_termination = true
  }

  
  network {
    uuid = vkcs_networking_network.compute.id
  }

  depends_on = [
    vkcs_networking_network.compute,
    vkcs_networking_subnet.compute
  ]
}

resource "vkcs_compute_keypair" "test-keypair" {
  name       = "user31-exam"
  public_key = file("./keys/id_rsa.pub")
}

resource "vkcs_networking_floatingip" "fip" {
  pool = data.vkcs_networking_network.extnet.name
}

resource "vkcs_compute_floatingip_associate" "fip" {
  floating_ip = vkcs_networking_floatingip.fip.address
  instance_id = vkcs_compute_instance.compute.id
}



output "instance_fip" {
  value = vkcs_networking_floatingip.fip.address
}