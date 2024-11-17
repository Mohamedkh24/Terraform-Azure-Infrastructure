# Terraform-Azure-Infrastructure

This project automates the deployment of an Azure infrastructure using Terraform. It implements a **Hub-Spoke VNet topology** with a private endpoint for a SQL Database, load balancers, and virtual machines distributed across multiple availability zones.

## Architecture Overview
![Arch](https://github.com/user-attachments/assets/3e132f4b-fbb0-4065-933e-93a9123ca2ba)

The deployed architecture includes:

1. **Hub VNet**:
   - Contains:
     - Public and private subnets.
     - Load balancers (public and private).
     - Virtual machines (VMs) spread across **Availability Zone 0** and **Availability Zone 1**.

2. **Spoke VNet**:
   - Connected to the Hub VNet through **VNet Peering**.
   - Contains:
     - A **private DNS zone** linked to a private endpoint.
     - A private subnet for the Azure Private Endpoint.

3. **Azure SQL Database**:
   - Accessed through a private endpoint secured via the private DNS zone.

4. **Storage Accounts**:
   - Hosted in the private subnet and accessible via the private load balancer.

---

## Features

### Hub-Spoke Networking
- VNet peering between Hub and Spoke VNets for secure communication.
- Segregation of public and private resources.

### Load Balancers
- **Public Load Balancer**: Distributes incoming traffic to VMs in Subnet1.
- **Private Load Balancer**: Balances traffic across VMs in Subnet2.

### Private Endpoint and DNS Zone
- A **Private DNS Zone** ensures name resolution for the Azure SQL Database through the private endpoint.
- Prevents public exposure of the database.

### Availability Zones
- Resources (VMs) are distributed across availability zones to ensure high availability and fault tolerance.

---

## Resources Deployed
### Hub VNet
- #### Subnets:
   - Subnet1: Hosts VMs and public load balancer.
   - Subnet2: Hosts VMs and private load balancer.
- #### Load Balancers:
   - Public Load Balancer: Distributes traffic to VMs in Subnet1.
   - Private Load Balancer: Balances internal traffic for VMs in Subnet2.
### Spoke VNet
- #### Private DNS Zone:
   - Provides name resolution for the private endpoint.
- #### Private Endpoint:
   - Secures access to Azure SQL Database.
### Azure SQL Database
   - SQL Server and database provisioned with private access only.
### Virtual Machines
   - 4 VMs distributed across two subnets and availability zones for redundancy.
