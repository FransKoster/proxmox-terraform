output "vm_id" {
  description = "The Proxmox VM ID."
  value       = proxmox_vm_qemu.this.vmid
}

output "name" {
  description = "The VM name."
  value       = proxmox_vm_qemu.this.name
}

output "target_node" {
  description = "The Proxmox node hosting the VM."
  value       = proxmox_vm_qemu.this.target_node
}

output "default_ipv4_address" {
  description = "The IPv4 address reported by the guest agent, when available."
  value       = proxmox_vm_qemu.this.default_ipv4_address
}

output "default_ipv6_address" {
  description = "The IPv6 address reported by the guest agent, when available."
  value       = proxmox_vm_qemu.this.default_ipv6_address
}
