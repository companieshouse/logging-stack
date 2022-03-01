write_files:
  - path: /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json
    owner: root:root
    permissions: 0664
    content: |
      {
        "agent": {
          "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
          "metrics_collection_interval": 60,
          "region": "${region}",
          "run_as_user": "cwagent",
          "debug": false
        },
        "logs": {
          "logs_collected": {
            "files": {
              "collect_list": [
                {
                  "file_path": "/var/log/kibana",
                  "log_group_name": "${log_group_name}",
                  "log_stream_name": "{instance_id}_{hostname}",
                  "timezone": "Local"
                }
              ]
            }
          }
        }
      }
