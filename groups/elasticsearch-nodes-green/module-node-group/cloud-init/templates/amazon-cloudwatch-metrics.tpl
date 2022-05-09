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
                "Role": "elasticsearch"
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
                "Role": "elasticsearch"
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
                "Role": "elasticsearch"
              },
              "measurement": [
                "free",
                "total",
                "used",
                "used_percent"
              ],
              "resources": [
                "/",
                "/var/lib/elasticsearch"
              ],
              "drop_device": true
            },
            "net": {
              "append_dimensions": {
                "Role": "elasticsearch"
              },
              "measurement": [
                "net_bytes_recv",
                "net_bytes_sent"
              ]
            },
            "swap": {
              "append_dimensions": {
                "Role": "elasticsearch"
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
