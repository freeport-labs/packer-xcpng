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
  default     = "xcp-ng-8.2.1-uefi.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "iso_url" {
  type    = string
  default = "https://mirrors.xcp-ng.org/isos/8.2/xcp-ng-8.2.1.iso?https=1"
}

/* variable "centos8_sha256sum_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/centos/8.4.2105/isos/x86_64/CHECKSUM"
} */

source "qemu" "xcp-ng" {
  efi_boot       = true
  boot_command     = [
    "e",
    "<down>",
    "<down>",
    "<down>",
    "<end> ",
    "answerfile_device=eth0 answerfile=http://{{ .HTTPIP }}:{{ .HTTPPort }}/answerfile.xml install",
    "<leftCtrlOn>x<leftCtrlOff>",
  ]
  boot_wait        = "6s"
  communicator     = "none"
  disk_size        = "60G"
  headless         = false
  http_directory   = "http"
  iso_checksum     = "none"
  iso_url          = var.iso_url
  memory           = 8192
  qemuargs         = [["-serial", "stdio"]]
  shutdown_timeout = "1h"
  output_directory = "output"
}

build {
  sources = ["source.qemu.xcp-ng"]

    post-processors {
      post-processor shell-local {
        inline = [
          "cd output",
          "tar -czvf ${var.filename} *",
          "mv ${var.filename} .."
        ]
      }
  }
}
