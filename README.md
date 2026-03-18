<div align="center">

<img src="https://img.shields.io/badge/Terraform-1.0%2B-7B42BC?style=for-the-badge&logo=terraform&logoColor=white"/>
<img src="https://img.shields.io/badge/AWS-us--east--1-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white"/>
<img src="https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Status-Active-22c55e?style=for-the-badge"/>

<br/>
<br/>

# 🏗️ Terraform AWS Infrastructure Module

### Modular, reusable Terraform configuration to provision a production-ready  
### **VPC + Public Subnet + EC2 Instance** on AWS with Security Group controls.

<br/>

[📋 Overview](#-overview) • [🗂️ Structure](#️-project-structure) • [🏛️ Architecture](#️-architecture) • [📦 Modules](#-modules) • [🚀 Quick Start](#-quick-start) • [📌 Notes](#-notes)

---

</div>

## 📋 Overview

This project provisions core AWS networking and compute infrastructure using a **modular Terraform approach**. The VPC and EC2 configurations are separated into independent, reusable modules — making it easy to maintain, extend, and compose into larger infrastructure pipelines.

| Component | Resource | Value |
|-----------|----------|-------|
| **Networking** | VPC | `192.21.0.0/16` — `fct_vpc` |
| **Networking** | Public Subnet | `192.21.0.0/20` — `us-east-1a` |
| **Compute** | EC2 Instance | `t3.micro` — `my_ec2` |
| **Security** | Security Group | SSH (22) + HTTP (80) inbound |
| **Region** | AWS | `us-east-1` |

---

## 🗂️ Project Structure

```
terraform-modules-vpc-main/
│
├── 📄 main.tf                        # Root: provider + module wiring
│
└── 📁 modules/
    │
    ├── 📁 vpc/
    │   ├── main.tf                   # aws_vpc + aws_subnet
    │   ├── variable.tf               # vpc_cidr, subnet_cidr, az
    │   └── output.tf                 # vpc_id, subnet_id
    │
    └── 📁 ec2/
        ├── main.tf                   # aws_instance + aws_security_group
        └── variable.tf               # ami_id, instance_type, subnet_id, vpc_id
```

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   AWS Region: us-east-1                  │
│                                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │            VPC: fct_vpc  (192.21.0.0/16)          │  │
│  │                                                   │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │   Public Subnet: public_subnet               │  │  │
│  │  │   CIDR: 192.21.0.0/20  |  AZ: us-east-1a   │  │  │
│  │  │                                             │  │  │
│  │  │   ┌─────────────────────────────────────┐   │  │  │
│  │  │   │  EC2: my_ec2  (t3.micro)            │   │  │  │
│  │  │   │  AMI: ami-02dfbd4ff395f2a1b         │   │  │  │
│  │  │   │                                     │   │  │  │
│  │  │   │  Security Group: new_sg             │   │  │  │
│  │  │   │  ├─ Inbound  → TCP :22  (SSH)       │   │  │  │
│  │  │   │  ├─ Inbound  → TCP :80  (HTTP)      │   │  │  │
│  │  │   │  └─ Outbound → ALL  0.0.0.0/0       │   │  │  │
│  │  │   └─────────────────────────────────────┘   │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Modules

### 🔷 `modules/vpc` — Networking

Provisions a VPC and a public subnet with configurable CIDR and Availability Zone.

**Resources created:**
- `aws_vpc` — Main VPC (`fct_vpc`)
- `aws_subnet` — Public Subnet (`public_subnet`)

#### Input Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vpc_cidr` | `string` | `"192.21.0.0/16"` | CIDR block for the VPC |
| `subnet_cidr` | `string` | `"192.21.0.0/20"` | CIDR block for the public subnet |
| `az` | `string` | `"us-east-1a"` | Availability Zone for the subnet |

#### Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | The ID of the created VPC |
| `subnet_id` | The ID of the created public subnet |

---

### 🔶 `modules/ec2` — Compute

Provisions an EC2 instance inside the VPC subnet, along with a Security Group allowing SSH and HTTP access.

**Resources created:**
- `aws_instance` — EC2 instance (`my_ec2`)
- `aws_security_group` — Security Group (`new_sg`)

#### Input Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ami_id` | `string` | `"ami-02dfbd4ff395f2a1b"` | AMI ID for the EC2 instance |
| `insatnce_type` | `string` | `"t3.micro"` | EC2 instance type |
| `subnet_id` | `string` | *(required)* | Subnet ID — passed from VPC module output |
| `vpc_id` | `string` | *(required)* | VPC ID — passed from VPC module output |

#### Security Group Rules

| Direction | Protocol | Port Range | Source / Destination |
|-----------|----------|------------|----------------------|
| Inbound | TCP | `22` (SSH) | *(not restricted — see Notes)* |
| Inbound | TCP | `80` (HTTP) | *(not restricted — see Notes)* |
| Outbound | All | All | `0.0.0.0/0` |

---

## 🔗 Module Wiring (`main.tf`)

The root configuration wires the two modules together, passing VPC outputs directly into EC2 inputs:

```hcl
provider "aws" {
  region = "us-east-1"
}

# Step 1: Provision VPC and Subnet
module "vpc" {
  source = "./modules/vpc"
}

# Step 2: Provision EC2 using VPC outputs
module "subnet" {
  source    = "./modules/ec2"
  subnet_id = module.vpc.subnet_id   # ← from vpc/output.tf
  vpc_id    = module.vpc.vpc_id      # ← from vpc/output.tf
}
```

---

## 🚀 Quick Start

### Prerequisites

Ensure the following tools are installed and configured:

```bash
# Verify Terraform
terraform -version   # >= 1.0.0

# Verify AWS CLI
aws --version        # >= 2.x

# Configure AWS credentials
aws configure
```

### Deployment Steps

```bash
# 1. Clone the repository
git clone https://github.com/shubhamtippe9/terraform-modules-vpc.git
cd terraform-modules-vpc-main

# 2. Initialize Terraform (downloads AWS provider)
terraform init

# 3. Preview the execution plan
terraform plan

# 4. Apply the infrastructure
terraform apply

# 5. Destroy when no longer needed
terraform destroy
```

---

## 📌 Notes

> ⚠️ **AMI Region Lock** — The default AMI `ami-02dfbd4ff395f2a1b` is specific to `us-east-1`. If you change the region, update `ami_id` with the correct AMI for that region.

> ⚠️ **Security Group CIDR** — The inbound rules for SSH (port 22) and HTTP (port 80) currently have no `cidr_blocks` restriction. For production environments, restrict these to known IP ranges:
> ```hcl
> ingress {
>   from_port   = 22
>   to_port     = 22
>   protocol    = "tcp"
>   cidr_blocks = ["YOUR.IP.ADDRESS/32"]
> }
> ```

> ℹ️ **No Internet Gateway** — This module does not provision an Internet Gateway or NAT Gateway. Add these resources to the VPC module if you need the EC2 instance to be publicly reachable or require outbound internet access.

> ℹ️ **Typo in Variable** — The variable `insatnce_type` in `modules/ec2/variable.tf` contains a typo (should be `instance_type`). This is preserved for compatibility but consider fixing in a future update.

---

## 🛠️ Requirements

| Tool | Minimum Version |
|------|----------------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | `>= 1.0.0` |
| [AWS CLI](https://aws.amazon.com/cli/) | `>= 2.0` |
| [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) | `>= 4.0` |

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ by **Shubham Tippe**  
[![GitHub](https://img.shields.io/badge/GitHub-shubhamtippe9-181717?style=flat&logo=github)](https://github.com/shubhamtippe9)

</div>
