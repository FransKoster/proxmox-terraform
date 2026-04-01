locals {
  effective_networks = length(var.networks) > 0 ? var.networks : [
    {
      id        = 0
      model     = "virtio"
      bridge    = "vmbr0"
      tag       = null
      firewall  = false
      link_down = false
      mtu       = null
      rate      = null
      queues    = null
      macaddr   = null
    }
  ]

  effective_disks = concat(
    [
      {
        slot       = var.boot_disk.slot
        type       = "disk"
        storage    = var.boot_disk.storage
        size       = var.boot_disk.size
        format     = var.boot_disk.format
        cache      = var.boot_disk.cache
        discard    = var.boot_disk.discard
        emulatessd = var.boot_disk.emulatessd
        iothread   = var.boot_disk.iothread
        replicate  = var.boot_disk.replicate
        backup     = var.boot_disk.backup
        readonly   = var.boot_disk.readonly
      }
    ],
    var.additional_disks
  )
}

resource "proxmox_vm_qemu" "this" {
  name                   = var.name
  target_node            = var.target_node
  vmid                   = var.vmid
  desc                   = var.description
  clone                  = var.clone
  full_clone             = var.full_clone
  os_type                = "cloud-init"
  qemu_os                = var.qemu_os
  agent                  = var.agent_enabled ? 1 : 0
  vm_state               = var.vm_state
  onboot                 = var.onboot
  boot                   = var.boot_order
  bootdisk               = var.boot_disk.slot
  bios                   = var.bios
  scsihw                 = var.scsihw
  cores                  = var.cores
  sockets                = var.sockets
  memory                 = var.memory
  balloon                = var.balloon
  tablet                 = var.tablet
  automatic_reboot       = var.automatic_reboot
  ci_wait                = var.ci_wait
  ciuser                 = var.ciuser
  cipassword             = var.cipassword
  ciupgrade              = var.ciupgrade
  cicustom               = var.cicustom
  sshkeys                = var.sshkeys
  nameserver             = var.nameserver
  searchdomain           = var.searchdomain
  ipconfig0              = var.ipconfig0
  ipconfig1              = var.ipconfig1
  ipconfig2              = var.ipconfig2
  skip_ipv4              = var.skip_ipv4
  skip_ipv6              = var.skip_ipv6
  tags                   = length(var.tags) == 0 ? null : join(",", var.tags)
  pool                   = var.pool
  startup                = var.startup
  protection             = var.protection
  force_create           = var.force_create
  define_connection_info = false

  dynamic "serial" {
    for_each = var.serials

    content {
      id   = serial.value.id
      type = serial.value.type
    }
  }

  dynamic "network" {
    for_each = local.effective_networks

    content {
      id        = network.value.id
      model     = network.value.model
      bridge    = network.value.bridge
      tag       = network.value.tag
      firewall  = network.value.firewall
      link_down = network.value.link_down
      mtu       = network.value.mtu
      rate      = network.value.rate
      queues    = network.value.queues
      macaddr   = network.value.macaddr
    }
  }

  dynamic "disk" {
    for_each = local.effective_disks

    content {
      slot       = disk.value.slot
      type       = disk.value.type
      storage    = disk.value.storage
      size       = disk.value.size
      format     = try(disk.value.format, null)
      cache      = try(disk.value.cache, null)
      discard    = try(disk.value.discard, null)
      emulatessd = try(disk.value.emulatessd, null)
      iothread   = try(disk.value.iothread, null)
      replicate  = try(disk.value.replicate, null)
      backup     = try(disk.value.backup, null)
      readonly   = try(disk.value.readonly, null)
    }
  }

  lifecycle {
    precondition {
      condition     = length(local.effective_networks) > 0
      error_message = "At least one network interface must be configured."
    }

    precondition {
      condition     = length(distinct([for disk in local.effective_disks : disk.slot])) == length(local.effective_disks)
      error_message = "Disk slots must be unique."
    }

    precondition {
      condition     = length(distinct([for network in local.effective_networks : network.id])) == length(local.effective_networks)
      error_message = "Network interface ids must be unique."
    }
  }
}
