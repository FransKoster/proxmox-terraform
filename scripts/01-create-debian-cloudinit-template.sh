#!/usr/bin/env bash

set -euo pipefail

# ===== CONFIG =====
VMID=9000
ACTION="create-image"
NAME="debian-13-cloudinit"
STORAGE="local-lvm"
BRIDGE="vmbr0"
MEMORY=2048
CORES=2
IMAGE_URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
IMAGE_FILE="debian-13.qcow2"
CI_USER="debian"
SSH_KEY_FILE="$HOME/.ssh/id_rsa.pub"

# ==================

usage() {
  cat <<EOF
Usage: $0 [--vmid <id>] [--action <create-image|create-template>]

Options:
  -v, --vmid      VM ID to use (default: ${VMID})
  -a, --action    Action to run: create-image or create-template (default: ${ACTION})
  -h, --help      Show this help message
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--vmid)
        [[ $# -lt 2 ]] && { echo "Missing value for $1" >&2; usage; exit 1; }
        VMID="$2"
        shift 2
        ;;
      -a|--action)
        [[ $# -lt 2 ]] && { echo "Missing value for $1" >&2; usage; exit 1; }
        ACTION="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage
        exit 1
        ;;
    esac
  done
}

validate_args() {
  if ! [[ "$VMID" =~ ^[0-9]+$ ]]; then
    echo "VMID must be numeric, got: ${VMID}" >&2
    exit 1
  fi

  if [[ "$ACTION" != "create-image" && "$ACTION" != "create-template" ]]; then
    echo "Action must be one of: create-image, create-template" >&2
    exit 1
  fi
}

create_image() {
  echo "==> Downloading Debian cloud image..."
  wget -O "${IMAGE_FILE}" "${IMAGE_URL}"

  echo "==> Creating VM ${VMID}..."
  qm create "${VMID}" \
    --name "${NAME}" \
    --memory "${MEMORY}" \
    --cores "${CORES}" \
    --net0 "virtio,bridge=${BRIDGE}"

  echo "==> Importing disk..."
  qm importdisk "${VMID}" "${IMAGE_FILE}" "${STORAGE}"

  echo "==> Attaching disk..."
  qm set "${VMID}" \
    --scsihw virtio-scsi-pci \
    --scsi0 "${STORAGE}:vm-${VMID}-disk-0"

  echo "==> Adding cloud-init drive..."
  qm set "${VMID}" --ide2 "${STORAGE}:cloudinit"

  echo "==> Setting boot options..."
  qm set "${VMID}" --boot c --bootdisk scsi0

  echo "==> Enabling serial console (recommended for cloud images)..."
  qm set "${VMID}" --serial0 socket --vga serial0

  echo "==> Configuring cloud-init user..."
  qm set "${VMID}" --ciuser "${CI_USER}"

  echo "==> Adding SSH key..."
  qm set "${VMID}" --sshkeys "${SSH_KEY_FILE}"

  echo "==> Setting DHCP networking..."
  qm set "${VMID}" --ipconfig0 ip=dhcp

  echo "==> Cleaning up image file..."
  rm -f "${IMAGE_FILE}"

  echo "==> DONE: VM image ${NAME} (VMID ${VMID}) is ready."
}

create_template() {
  echo "==> Converting VM ${VMID} to template..."
  qm template "${VMID}"
  echo "==> DONE: Template ${NAME} (VMID ${VMID}) is ready."
}

parse_args "$@"
validate_args

case "$ACTION" in
  create-image)
    create_image
    ;;
  create-template)
    create_template
    ;;
esac