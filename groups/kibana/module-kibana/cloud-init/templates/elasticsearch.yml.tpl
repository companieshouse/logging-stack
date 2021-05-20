write_files:
  - path: /etc/elasticsearch/elasticsearch.yml
    owner: ${elastic_search_service_user}:${elastic_search_service_group}
    permissions: 0660
    content: |
      cluster.name: ${environment}
      discovery.ec2.availability_zones: ${discovery_availability_zones}
      discovery.ec2.endpoint: ec2.${region}.amazonaws.com
      discovery.ec2.tag.ElasticSearchMasterNode: true
      discovery.ec2.tag.Environment: ${environment}
      discovery.seed_providers: ec2
      network.bind_host: 0.0.0.0
      network.publish_host: _ec2:privateIpv4_
      node.roles:%{ if length(roles) == 0 } []%{ endif }
      %{ for role in roles }
        - ${role}
      %{ endfor }
      path.data: /var/lib/elasticsearch
      path.logs: /var/log/elasticsearch
