# Custom Data Script to install IIS and set content for WS-VM1
data "template_file" "script_iis_vm1" {
  template = <<-EOF
    <powershell>
      Install-WindowsFeature -name Web-Server -IncludeManagementTools
      Set-Content -Path "C:\\inetpub\\wwwroot\\index.html" -Value "<h1>Hello from web1</h1>"
    </powershell>
  EOF
}

# Custom Data Script to install IIS and set content for WS-VM2
data "template_file" "script_iis_vm2" {
  template = <<-EOF
    <powershell>
      Install-WindowsFeature -name Web-Server -IncludeManagementTools
      Set-Content -Path "C:\\inetpub\\wwwroot\\index.html" -Value "<h1>Hello from web2</h1>"
    </powershell>
  EOF
}

# Local variables to hold resource values
locals {
  storage_account_name = azurerm_storage_account.lnxstorageacc12.name
  storage_account_key  = azurerm_storage_account.lnxstorageacc12.primary_access_key
  file_share_name      = azurerm_storage_share.premiumfileshare.name
  mount_point          = "/mnt/azurefile"
}
# Custom Data Script to mount the file share
data "template_file" "mount_script" {
  template = file("./mount_script.sh")
  vars = {
    storage_account_name = local.storage_account_name
    storage_account_key  = local.storage_account_key
    file_share_name      = local.file_share_name
    mount_point          = local.mount_point
  }
}
# Custom Data Script to install Apache and set content for LS-VM1
data "template_file" "script_lnx_vm1" {
  template = <<-EOF
                ${data.template_file.mount_script.rendered}
                #!/bin/bash
                sudo apt update
                sudo apt install -y apache2
                echo "Welcome from Apache 1" | sudo tee /var/www/html/index.html
                sudo systemctl restart apache2
              EOF
}

# Custom Data Script to install Apache and set content for LS-VM2
data "template_file" "script_lnx_vm2" {
  template = <<-EOF
                ${data.template_file.mount_script.rendered}
                #!/bin/bash
                sudo apt update
                sudo apt install -y apache2
                echo "Welcome from Apache 2" | sudo tee /var/www/html/index.html
                sudo systemctl restart apache2
              EOF
}