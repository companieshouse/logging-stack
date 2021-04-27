write_files:
  - path: /etc/kibana/kibana.yml
    owner: ${kibana_service_user}:${kibana_service_group}
    permissions: 0660
    content: |
      server.host: 0.0.0.0
