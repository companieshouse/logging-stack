write_files:
  - path: /etc/elasticsearch/elasticsearch.yml
    owner: ${service_user}:${service_group}
    permissions: 0660
    content: |
      cluster.name: ${environment}%{ for role in roles }%{ if role == "master" }
      cluster.routing.allocation.awareness.attributes: availability_zone%{ endif }%{ endfor }
      discovery.ec2.availability_zones: ${discovery_availability_zones}
      discovery.ec2.endpoint: ec2.${region}.amazonaws.com
      discovery.ec2.tag.ElasticSearchMasterNode: true
      discovery.ec2.tag.Environment: ${environment}
      discovery.seed_providers: ec2
      network.host: _ec2:privateIpv4_%{ if availability_zone != null }
      node.attr.availability_zone: ${availability_zone}%{ endif }
      node.attr.box_type: ${box_type}
      node.roles:%{ for role in roles }
        - ${role}%{ endfor }
      path.data: /var/lib/elasticsearch
      path.logs: /var/log/elasticsearch
