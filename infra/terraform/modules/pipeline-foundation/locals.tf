locals {
  tags = merge(
    {
      managed-by  = "terraform"
      repository  = "azure-devops-enterprise-pipelines"
      environment = var.environment
    },
    var.tags,
  )
}
