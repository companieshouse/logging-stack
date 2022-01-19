runcmd:
  %{~ for block_device in lvm_block_devices ~}
  %{ if block_device.filesystem_resize_tool != "" }
  - 'echo "Resizing volume (GiB): ${block_device.lvm_logical_volume_device_node} -> [${block_device.aws_volume_size_gb}]"'
  - pvresize ${block_device.lvm_physical_volume_device_node}
  - lvresize -l +100%FREE ${block_device.lvm_logical_volume_device_node}
  - ${block_device.filesystem_resize_tool} ${block_device.lvm_logical_volume_device_node}
  %{ endif }
  %{~ endfor ~}
  - xfs_growfs ${root_volume_device_node}
  - rm /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
  - systemctl enable amazon-cloudwatch-agent
  - systemctl start amazon-cloudwatch-agent
  - systemctl enable elasticsearch
  - systemctl start elasticsearch
  - systemctl enable kibana
  - systemctl start kibana
