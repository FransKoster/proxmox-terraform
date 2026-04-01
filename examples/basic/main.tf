terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

module "vm" {
  source = "../.."

  name        = var.name
  target_node = var.target_node
  clone       = var.clone

  ciuser     = var.ciuser
  sshkeys    = var.sshkeys
  ipconfig0  = var.ipconfig0
  cicustom   = var.cicustom
  nameserver = var.nameserver

  cores  = var.cores
  memory = var.memory

  boot_disk = {
    storage = var.disk_storage
    size    = var.disk_size
  }

  networks = [
    {
      id     = 0
      bridge = var.bridge
      tag    = var.vlan_tag
    }
  ]

  tags = ["terraform", "debian"]
}
