variable "pm_api_url" {
  description = "Proxmox API URL, for example https://pve.example.com:8006/api2/json."
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API token id, for example terraform@pve!deploy."
  type        = string
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret."
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Allow insecure TLS for self-signed Proxmox certificates."
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the VM to create."
  type        = string
  default     = "debian-vm-01"
}

variable "target_node" {
  description = "Proxmox node on which the VM will be created."
  type        = string
}

variable "clone" {
  description = "Name of the Debian cloud-init template available on the target node."
  type        = string
  default     = "debian-12-cloudinit-template"
}

variable "ciuser" {
  description = "Cloud-init user to create."
  type        = string
  default     = "debian"
}

variable "sshkeys" {
  description = "Newline-delimited SSH public keys to add for the cloud-init user."
  type        = string
}

variable "ipconfig0" {
  description = "Cloud-init IP config for net0."
  type        = string
  default     = "ip=dhcp"
}

variable "cicustom" {
  description = "Optional Proxmox snippet reference such as user=local:snippets/user-data.yaml."
  type        = string
  default     = null
}

variable "nameserver" {
  description = "Optional DNS server for cloud-init."
  type        = string
  default     = null
}

variable "cores" {
  description = "vCPU cores per socket."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MiB."
  type        = number
  default     = 2048
}

variable "disk_storage" {
  description = "Storage backend that holds the VM disk."
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Boot disk size."
  type        = string
  default     = "20G"
}

variable "bridge" {
  description = "Network bridge for net0."
  type        = string
  default     = "vmbr0"
}

variable "vlan_tag" {
  description = "Optional VLAN tag for net0."
  type        = number
  default     = null
}
