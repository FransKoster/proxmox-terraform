variable "name" {
  description = "Name of the VM in Proxmox."
  type        = string
}

variable "target_node" {
  description = "Name of the Proxmox node where the VM will run."
  type        = string
}

variable "clone" {
  description = "Name of the cloud-init enabled template to clone."
  type        = string
}

variable "vmid" {
  description = "Optional fixed VM ID. Leave null to let Proxmox pick the next available ID."
  type        = number
  default     = null
}

variable "description" {
  description = "Optional VM description shown in Proxmox notes."
  type        = string
  default     = null
}

variable "full_clone" {
  description = "Whether to create a full clone from the template."
  type        = bool
  default     = true
}

variable "qemu_os" {
  description = "Guest OS type passed to Proxmox."
  type        = string
  default     = "l26"
}

variable "agent_enabled" {
  description = "Enable the QEMU guest agent. The guest image must have qemu-guest-agent installed."
  type        = bool
  default     = true
}

variable "vm_state" {
  description = "Desired VM power state after apply."
  type        = string
  default     = "running"

  validation {
    condition     = contains(["running", "stopped", "started"], var.vm_state)
    error_message = "vm_state must be one of: running, stopped, started."
  }
}

variable "onboot" {
  description = "Start the VM automatically when the Proxmox node boots."
  type        = bool
  default     = false
}

variable "boot_order" {
  description = "Boot order as expected by the provider, for example order=scsi0;net0."
  type        = string
  default     = "order=scsi0;net0"
}

variable "bios" {
  description = "BIOS type for the VM."
  type        = string
  default     = "seabios"

  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "bios must be either seabios or ovmf."
  }
}

variable "scsihw" {
  description = "SCSI controller type."
  type        = string
  default     = "virtio-scsi-single"
}

variable "cores" {
  description = "Number of CPU cores per socket."
  type        = number
  default     = 2
}

variable "sockets" {
  description = "Number of CPU sockets."
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory for the VM in MiB."
  type        = number
  default     = 2048
}

variable "balloon" {
  description = "Balloon memory target in MiB. Set to 0 to disable ballooning."
  type        = number
  default     = 0
}

variable "tablet" {
  description = "Enable the tablet device."
  type        = bool
  default     = true
}

variable "automatic_reboot" {
  description = "Let the provider reboot the VM automatically when required."
  type        = bool
  default     = true
}

variable "ci_wait" {
  description = "Seconds to wait before cloud-init provisioning continues."
  type        = number
  default     = 30
}

variable "ciuser" {
  description = "Cloud-init username."
  type        = string
  default     = "debian"
}

variable "cipassword" {
  description = "Optional cloud-init password."
  type        = string
  default     = null
  sensitive   = true
}

variable "ciupgrade" {
  description = "Whether cloud-init should upgrade packages on first boot."
  type        = bool
  default     = false
}

variable "cicustom" {
  description = "Optional custom cloud-init snippet reference, for example user=local:snippets/user-data.yaml."
  type        = string
  default     = null
}

variable "sshkeys" {
  description = "Newline-delimited SSH public keys added to the cloud-init user."
  type        = string
  default     = null
}

variable "nameserver" {
  description = "DNS server passed to cloud-init."
  type        = string
  default     = null
}

variable "searchdomain" {
  description = "DNS search domain passed to cloud-init."
  type        = string
  default     = null
}

variable "ipconfig0" {
  description = "Cloud-init network config for net0. Example: ip=dhcp or ip=192.168.1.10/24,gw=192.168.1.1."
  type        = string
  default     = "ip=dhcp"
}

variable "ipconfig1" {
  description = "Cloud-init network config for net1."
  type        = string
  default     = null
}

variable "ipconfig2" {
  description = "Cloud-init network config for net2."
  type        = string
  default     = null
}

variable "skip_ipv4" {
  description = "Skip waiting for an IPv4 address from the guest agent."
  type        = bool
  default     = false
}

variable "skip_ipv6" {
  description = "Skip waiting for an IPv6 address from the guest agent."
  type        = bool
  default     = true
}

variable "tags" {
  description = "List of Proxmox tags applied to the VM."
  type        = list(string)
  default     = []
}

variable "pool" {
  description = "Optional Proxmox pool for the VM."
  type        = string
  default     = null
}

variable "startup" {
  description = "Optional startup ordering string as supported by Proxmox, for example order=10,up=30."
  type        = string
  default     = null
}

variable "protection" {
  description = "Protect the VM from accidental deletion in Proxmox."
  type        = bool
  default     = false
}

variable "force_create" {
  description = "Always create a new VM instead of reconfiguring a VM with the same name."
  type        = bool
  default     = false
}

variable "boot_disk" {
  description = "Primary boot disk configuration."
  type = object({
    slot       = optional(string, "scsi0")
    storage    = string
    size       = string
    format     = optional(string, "raw")
    cache      = optional(string)
    discard    = optional(bool, true)
    emulatessd = optional(bool, true)
    iothread   = optional(bool, true)
    replicate  = optional(bool, true)
    backup     = optional(bool, true)
    readonly   = optional(bool, false)
  })

  default = {
    slot       = "scsi0"
    storage    = "local-lvm"
    size       = "20G"
    format     = "raw"
    discard    = true
    emulatessd = true
    iothread   = true
    replicate  = true
    backup     = true
    readonly   = false
  }
}

variable "additional_disks" {
  description = "Additional disk definitions appended after the boot disk."
  type = list(object({
    slot       = string
    type       = optional(string, "disk")
    storage    = string
    size       = string
    format     = optional(string, "raw")
    cache      = optional(string)
    discard    = optional(bool, true)
    emulatessd = optional(bool, true)
    iothread   = optional(bool, true)
    replicate  = optional(bool, true)
    backup     = optional(bool, true)
    readonly   = optional(bool, false)
  }))
  default = []
}

variable "networks" {
  description = "Network interfaces attached to the VM. The first entry becomes net0."
  type = list(object({
    id        = number
    model     = optional(string, "virtio")
    bridge    = string
    tag       = optional(number)
    firewall  = optional(bool, false)
    link_down = optional(bool, false)
    mtu       = optional(number)
    rate      = optional(number)
    queues    = optional(number)
    macaddr   = optional(string)
  }))
  default = []
}

variable "serials" {
  description = "Optional serial devices. For cloud-init guests, serial socket 0 is commonly useful."
  type = list(object({
    id   = number
    type = optional(string, "socket")
  }))
  default = [
    {
      id   = 0
      type = "socket"
    }
  ]
}
