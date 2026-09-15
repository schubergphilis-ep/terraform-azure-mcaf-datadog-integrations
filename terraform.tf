terraform {
  required_version = ">= 1.9"
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.9"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}