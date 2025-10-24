variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "cai-aks-test"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "mycai_test-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for nodes"
  type        = string
  default     = "Standard_B2s"  # Cost-optimized for testing
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling"
  type        = bool
  default     = false
}

variable "min_count" {
  description = "Minimum node count for auto-scaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum node count for auto-scaling"
  type        = number
  default     = 2
}

variable "enable_monitoring" {
  description = "Enable monitoring"
  type        = bool
  default     = true
}

variable "enable_rbac" {
  description = "Enable RBAC"
  type        = bool
  default     = true
}

variable "network_plugin" {
  description = "Network plugin"
  type        = string
  default     = "azure"
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
  default     = "TestPassword123!"
}

variable "test_api_key" {
  description = "Test API key"
  type        = string
  sensitive   = true
  default     = "test-api-key-12345"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "CAI-Kubernetes"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}