resource "azurerm_resource_group" "coastline" {
  name     = "rg-coastline-prod"
  location = "East US"

  tags = {
    company     = "Coastline Outfitters"
    environment = "production"
    owner       = "IT"
    cost_center = "IT-001"
  }
}

resource "azurerm_log_analytics_workspace" "coastline" {
  name                = "law-coastline-prod"
  location            = azurerm_resource_group.coastline.location
  resource_group_name = azurerm_resource_group.coastline.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    company     = "Coastline Outfitters"
    environment = "production"
    owner       = "IT"
    cost_center = "IT-001"
  }
}

resource "azurerm_virtual_network" "coastline" {
  name                = "vnet-coastline-prod"
  location            = azurerm_resource_group.coastline.location
  resource_group_name = azurerm_resource_group.coastline.name
  address_space       = ["10.10.0.0/16"]

  tags = {
    company     = "Coastline Outfitters"
    environment = "production"
    owner       = "IT"
    cost_center = "IT-001"
  }
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.coastline.name
  virtual_network_name = azurerm_virtual_network.coastline.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.coastline.name
  virtual_network_name = azurerm_virtual_network.coastline.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.coastline.name
  virtual_network_name = azurerm_virtual_network.coastline.name
  address_prefixes     = ["10.10.3.0/24"]
}

resource "azurerm_subnet" "mgmt" {
  name                 = "snet-mgmt"
  resource_group_name  = azurerm_resource_group.coastline.name
  virtual_network_name = azurerm_virtual_network.coastline.name
  address_prefixes     = ["10.10.4.0/24"]
}
