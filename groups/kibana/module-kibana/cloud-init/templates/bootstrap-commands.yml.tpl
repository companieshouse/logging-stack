runcmd:
  %{~ for block_device in lvm_block_devices ~}
  - pvresize ${block_device.lvm_physical_volume_device_node}
  - lvresize -l +100%FREE ${block_device.lvm_logical_volume_device_node}
  - ${block_device.filesystem_resize_tool} ${block_device.lvm_logical_volume_device_node}
  %{~ endfor ~}
  - xfs_growfs ${root_volume_device_node}
  - systemctl enable elasticsearch
  - systemctl start elasticsearch
  - systemctl enable kibana
  - systemctl start kibana
