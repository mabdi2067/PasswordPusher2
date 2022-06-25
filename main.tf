terraform {
  required_providers {
    docker = {
        source = "kreuzwerker/docker"
        version = "~>2.15.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
    version = "~>2.99.0"
    features {}
}

terraform {
    backend "azurerm" {
      resource_group_name = "abdi-test-2"
      storage_account_name = "abditeststorage82"
      container_name = "tfstate"
      key = "terraform.tfstate"
    }
}

resource "random_integer" "ri" {
  min = 10000
  max = 999999
}

resource "azurerm_resource_group" "ASP-RG" {
  name     = "Abdi-ASP-RG"
  location = "Canada Central"
  tags = {
    owner = "Mohamed Abdi"
    purpose = "Test-App"
  }
}

resource "azurerm_app_service_plan" "ASP-Abdi" {
  name                = "ASP-PP-${random_integer.ri.result}"
  location            = azurerm_resource_group.ASP-RG.location
  resource_group_name = azurerm_resource_group.ASP-RG.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }

}

#Create the web app, pass in the App Service Plan ID, and deploy code from a public GitHub repo
resource "azurerm_app_service" "webapp" {
  name                = "webapp-${random_integer.ri.result}"
  location            = azurerm_resource_group.ASP-RG.location
  resource_group_name = azurerm_resource_group.ASP-RG.name
  app_service_plan_id = azurerm_app_service_plan.ASP-Abdi.id

site_config {
    linux_fx_version = "mabdi23/pwpush"
    always_on        = "true"
  }
}
