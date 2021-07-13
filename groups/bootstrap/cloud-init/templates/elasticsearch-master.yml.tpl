write_files:
  - path: /etc/elasticsearch/elasticsearch.yml
    owner: ${elastic_search_service_user}:${elastic_search_service_group}
    permissions: 0660
    content: |
      cluster.initial_master_nodes:
        - ${service}-${environment}-bootstrap.${dns_zone_name}
      cluster.name: ${environment}
      cluster.routing.allocation.awareness.attributes: availability_zone
      discovery.ec2.availability_zones: ${discovery_availability_zones}
      discovery.ec2.endpoint: ec2.${region}.amazonaws.com
      discovery.ec2.tag.ElasticSearchMasterNode: true
      discovery.ec2.tag.Environment: ${environment}
      discovery.seed_providers: ec2
      network.host: _ec2:privateIpv4_
      node.roles:
        - master
      path.data: /var/lib/elasticsearch
      path.logs: /var/log/elasticsearch
