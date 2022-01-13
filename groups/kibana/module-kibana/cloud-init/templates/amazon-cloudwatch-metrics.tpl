write_files:
  - path: /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/amazon-cloudwatch-metrics.json
    owner: root:root
    permissions: 0664
    content: |
      {
        "metrics": {
          "namespace": "${metrics_namespace}",
          "metrics_collected": {
            "cpu": {
              "append_dimensions": {
                "Role": "web"
              },
              "measurement": [
                "usage_active",
                "usage_guest",
                "usage_idle",
                "usage_iowait",
                "usage_steal",
                "usage_system",
                "usage_user"
              ],
              "resources": [
                "*"
              ]
            },
            "mem": {
              "append_dimensions": {
                "Role": "web"
              },
              "measurement": [
                "available",
                "available_percent",
                "buffered",
                "cached",
                "free",
                "used",
                "used_percent"
              ]
            },
            "disk": {
              "append_dimensions": {
                "Role": "web"
              },
              "measurement": [
                "free",
                "total",
                "used",
                "used_percent"
              ],
              "resources": [
                "/"
              ],
              "drop_device": true
            },
            "swap": {
              "append_dimensions": {
                "Role": "web"
              },
              "measurement": [
                "free",
                "used",
                "used_percent"
              ]
            }
          },
          "append_dimensions": {
            "ImageId": "$${aws:ImageId}",
            "InstanceId": "$${aws:InstanceId}",
            "InstanceType": "$${aws:InstanceType}"
          },
          "aggregation_dimensions": [["InstanceId"], ["InstanceId", "InstanceType"]]
        }
      }
