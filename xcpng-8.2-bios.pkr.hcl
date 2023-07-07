packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}
variable "filename" {
  type        = string
  default     = "xcp-ng-8.2.1-bios-kernel-alt.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "iso_url" {
  type    = string
  default = "https://mirrors.xcp-ng.org/isos/8.2/xcp-ng-8.2.1.iso?https=1"
}

variable "root_pass_hash" {
  type    = string
  default = "root"
}

variable "xcp-ng-checksum" {
  type    = string
  default = "93853aba9a71900fe43fd5a0082e2af6ab89acd14168f058ffc89d311690a412"
}

source "qemu" "xcp-ng" {
  boot_command     = [
    "mboot.c32 /boot/xen.gz dom0_max_vcpus=1-16 dom0_mem=max:8192M com1=115200,8n1 console=com1,vga --- /boot/vmlinuz console=hvc0 console=tty0 kernel-alt answerfile=http://{{ .HTTPIP }}:{{ .HTTPPort }}/answerfile.xml install --- /install.img <enter><wait>"
  ]
  boot_wait        = "1s"
  communicator     = "none"
  disk_size        = "60G"
  headless         = false
  http_directory   = "http"
  iso_checksum     = "sha256:${var.xcp-ng-checksum}"
  iso_url          = var.iso_url
  memory           = 4096
  qemuargs         = [["-serial", "stdio"]]
  disk_interface   = "virtio-scsi"
  shutdown_timeout = "1h"
  output_directory = "output"
}

build {
  sources = ["source.qemu.xcp-ng"]

  provisioner "shell-local" {
    inline = [
      "echo 'Generate answerfile.xml'",
      "envsubst < templates/answerfile.tpl > http/answerfile.xml",
    ]
    environment_vars = [
      "ROOT_PASS_HASH=${var.root_pass_hash}",
    ]
  }

  post-processors {
    post-processor shell-local {
      inline = [
        "echo 'Change to output directory'",
        "cd output",
        "echo 'Create tarball of output file'",
        "tar -czvf ${var.filename} *",
        "echo 'Move tarball to artifacts directory'",
        "mv ${var.filename} ../artifacts/${var.filename}-$(date +%Y-%m-%d-%H%M%S).tar.gz",
        "echo 'Change back to root directory'",
        "cd ../",
        "echo 'Cleanup output directory'",
        "rm -rf output",
      ]
    }
  }
}
