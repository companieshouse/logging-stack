locals {
  cold_nodes_log_group_name = "${var.service}-${var.environment}-cold-nodes"
  hot_nodes_log_group_name = "${var.service}-${var.environment}-hot-nodes"
  master_nodes_log_group_name = "${var.service}-${var.environment}-master-nodes"
  warm_nodes_log_group_name = "${var.service}-${var.environment}-warm-nodes"
}
