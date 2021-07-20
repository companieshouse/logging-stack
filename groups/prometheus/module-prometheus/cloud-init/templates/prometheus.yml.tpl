write_files:

  - path: /etc/prometheus/prometheus.yml
    owner: prometheus:prometheus
    permissions: 0644
    content: |
      global:
        scrape_interval:     30s
        evaluation_interval: 30s

      scrape_configs:
        - job_name: 'prometheus'
          static_configs:
          - targets: ['localhost:9090','localhost:9100']

        - job_name: nodes
          scrape_interval: 60s
          scrape_timeout: 30s
          metrics_path: /metrics
          scheme: http
          ec2_sd_configs:
            - region: ${region}
              port: ${prometheus_metrics_port}
              filters:
                - name: tag:Environment
                  values: [${environment}]
                - name: tag:Service
                  values: [logging]
          relabel_configs:
            - source_labels: [__meta_ec2_tag_HostName]
              target_label: hostname

        - job_name: cold_nodes
          scrape_interval: 60s
          scrape_timeout: 30s
          metrics_path: /metrics
          scheme: http
          ec2_sd_configs:
            - region: ${region}
              port: ${prometheus_metrics_port}
              filters:
                - name: tag:Environment
                  values: [${environment}]
                - name: tag:Service
                  values: [logging]
                - name: tag:ElasticSearchColdNode
                  values: [true]
          relabel_configs:
            - source_labels: [__meta_ec2_private_ip]
              target_label: private_ip

        - job_name: warm_nodes
          scrape_interval: 60s
          scrape_timeout: 30s
          metrics_path: /metrics
          scheme: http
          ec2_sd_configs:
            - region: ${region}
              port: ${prometheus_metrics_port}
              filters:
                - name: tag:Environment
                  values: [${environment}]
                - name: tag:Service
                  values: [logging]
                - name: tag:ElasticSearchWarmNode
                  values: [true]
          relabel_configs:
            - source_labels: [__meta_ec2_private_ip]
              target_label: private_ip

        - job_name: hot_nodes
          scrape_interval: 60s
          scrape_timeout: 30s
          metrics_path: /metrics
          scheme: http
          ec2_sd_configs:
            - region: ${region}
              port: ${prometheus_metrics_port}
              filters:
                - name: tag:Environment
                  values: [${environment}]
                - name: tag:Service
                  values: [logging]
                - name: tag:ElasticSearchHotNode
                  values: [true]
          relabel_configs:
            - source_labels: [__meta_ec2_private_ip]
              target_label: private_ip

        - job_name: master_nodes
          scrape_interval: 60s
          scrape_timeout: 30s
          metrics_path: /metrics
          scheme: http
          ec2_sd_configs:
            - region: ${region}
              port: ${prometheus_metrics_port}
              filters:
                - name: tag:Environment
                  values: [${environment}]
                - name: tag:Service
                  values: [logging]
                - name: tag:ElasticSearchMasterNode
                  values: [true]
          relabel_configs:
            - source_labels: [__meta_ec2_private_ip]
              target_label: private_ip
