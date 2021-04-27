write_files:
  - path: /etc/elasticsearch/jvm.options
    owner: ${elastic_search_service_user}:${elastic_search_service_group}
    permissions: 0660
    content: |
      -Xms${heap_size_gigabytes}g
      -Xmx${heap_size_gigabytes}g

      8-13:-XX:+UseConcMarkSweepGC
      8-13:-XX:CMSInitiatingOccupancyFraction=75
      8-13:-XX:+UseCMSInitiatingOccupancyOnly

      14-:-XX:+UseG1GC
      14-:-XX:G1ReservePercent=25
      14-:-XX:InitiatingHeapOccupancyPercent=30

      -Djava.io.tmpdir=$${ES_TMPDIR}

      -XX:+HeapDumpOnOutOfMemoryError
      -XX:HeapDumpPath=/var/lib/elasticsearch
      -XX:ErrorFile=/var/log/elasticsearch/hs_err_pid%p.log

      8:-XX:+PrintGCDetails
      8:-XX:+PrintGCDateStamps
      8:-XX:+PrintTenuringDistribution
      8:-XX:+PrintGCApplicationStoppedTime
      8:-Xloggc:/var/log/elasticsearch/gc.log
      8:-XX:+UseGCLogFileRotation
      8:-XX:NumberOfGCLogFiles=32
      8:-XX:GCLogFileSize=64m

      9-:-Xlog:gc*,gc+age=trace,safepoint:file=/var/log/elasticsearch/gc.log:utctime,pid,tags:filecount=32,filesize=64m
