module "aks_test" {
  source = "../modules/aks"

  # Test-specific configuration
  cluster_name         = var.cluster_name
  resource_group_name  = var.resource_group_name
  location            = var.location
  kubernetes_version  = var.kubernetes_version
  
  # Test environment optimizations
  node_count          = var.node_count
  vm_size            = var.vm_size
  enable_auto_scaling = var.enable_auto_scaling
  min_count          = var.min_count
  max_count          = var.max_count
  
  # Test-specific features
  enable_monitoring   = var.enable_monitoring
  enable_rbac        = var.enable_rbac
  network_plugin     = var.network_plugin
  
  # Test environment tags
  tags = merge(var.tags, {
    Environment   = "test"
    Purpose      = "automated-testing"
    AutoCleanup  = "enabled"
    MaxLifetime  = "24h"
    CostCenter   = "engineering"
  })
}

# Test-specific resources
resource "azurerm_log_analytics_workspace" "test_logs" {
  name                = "${var.cluster_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                = "PerGB2018"
  retention_in_days   = 7  # Short retention for test

  tags = var.tags
}

resource "azurerm_application_insights" "test_insights" {
  name                = "${var.cluster_name}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.test_logs.id
  application_type    = "web"

  tags = var.tags
}

# Key Vault for test secrets
resource "azurerm_key_vault" "test_kv" {
  name                = "${replace(var.cluster_name, "-", "")}kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"
  
  # Test environment - shorter retention
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  enable_rbac_authorization = true

  tags = var.tags
}

# Current client configuration
data "azurerm_client_config" "current" {}

# Grant current user Key Vault access
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.test_kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Test database for integration testing
resource "azurerm_mssql_server" "test_sql" {
  name                         = "${var.cluster_name}-sql"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "testadmin"
  administrator_login_password = var.sql_admin_password
  
  # Test environment security (relaxed for testing)
  public_network_access_enabled = true

  tags = var.tags
}

resource "azurerm_mssql_database" "test_db" {
  name           = "testdb"
  server_id      = azurerm_mssql_server.test_sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 2  # Small size for testing
  sku_name       = "Basic"

  tags = var.tags
}

# Test secrets in Key Vault
resource "azurerm_key_vault_secret" "test_secrets" {
  for_each = {
    "sql-connection-string" = "Server=${azurerm_mssql_server.test_sql.fully_qualified_domain_name};Database=${azurerm_mssql_database.test_db.name};User Id=${azurerm_mssql_server.test_sql.administrator_login};Password=${var.sql_admin_password};Encrypt=true;TrustServerCertificate=true;"
    "application-insights-key" = azurerm_application_insights.test_insights.instrumentation_key
    "test-api-key" = var.test_api_key
    "redis-connection" = "localhost:6379"  # Will be updated when Redis is deployed
  }

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.test_kv.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

# Output kubeconfig for pipeline integration
resource "local_file" "kubeconfig" {
  content  = module.aks_test.kube_config_raw
  filename = "${path.module}/kubeconfig.yaml"
  
  depends_on = [module.aks_test]
}