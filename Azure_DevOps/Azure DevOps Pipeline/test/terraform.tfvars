cluster_name        = "cai-aks-test"
resource_group_name = "mycai_test-rg"
location           = "East US"
kubernetes_version = "1.28"

# Test-optimized sizing
node_count          = 1
vm_size            = "Standard_B2s"
enable_auto_scaling = false
min_count          = 1
max_count          = 2

# Monitoring and security
enable_monitoring = true
enable_rbac      = true
network_plugin   = "azure"

# Test secrets (use Azure Key Vault or environment variables in production)
sql_admin_password = "TestPassword123!"
test_api_key      = "test-api-key-67890"

tags = {
  Project      = "CAI-Kubernetes"
  Environment  = "test"
  ManagedBy    = "Terraform"
  Purpose      = "automated-testing"
  AutoCleanup  = "enabled"
  CostCenter   = "engineering"
}
