# Terraform IaC Training - Claude Context

## Project Overview

This is an **Insight Terraform Infrastructure-as-Code (IaC) Training** repository designed for hands-on learning of Terraform concepts and Azure cloud infrastructure management. The training is structured as a multi-day workshop with progressive difficulty levels.

## Project Structure

```
terraform-training/
├── Day1/          # Fundamentals (101 series)
├── Day2/          # Intermediate concepts (201 series)
├── Day3/          # Advanced topics (301 series)
└── .devcontainer/ # GitHub Codespaces configuration
```

### Day 1 - Fundamentals (101 Series)
Basic Terraform concepts and Azure connectivity:
- **101-workstation-config**: Environment setup
- **101-connect-azure**: Azure authentication and provider configuration
- **101-version-pinning-state-and-lock**: Version management and state locking
- **101-variables**: Variable declaration and usage
- **101-apply-plan-output**: Terraform workflow basics
- **101-virtual-machine**: Creating Azure VMs with Terraform

### Day 2 - Intermediate (201 Series)
Advanced state management and modularity:
- **201-locals-and-outputs**: Local values and output variables
- **201-remote-state**: Remote backend configuration
- **201-state-import**: Importing existing infrastructure
- **201-functions**: Terraform built-in functions
- **201-variable-validation-and-expressions**: Advanced variable features
- **201-modules**: Creating and using modules
- **201-unit-tests**: Testing Terraform code

### Day 3 - Advanced (301 Series)
Production patterns and best practices:
- **301-variable-types**: Complex variable types and usage
- **301-refactoring-and-state**: State manipulation and refactoring
- **301-common-traps**: Pitfalls and how to avoid them (count, dependencies, etc.)
- **301-complex-codebases**: Enterprise-scale patterns and structure

## Technology Stack

- **Terraform**: Latest version (installed via dev container)
- **Cloud Provider**: Microsoft Azure
- **Tools**:
  - Azure CLI
  - TFLint (Terraform linter)
  - Terragrunt (DRY Terraform wrapper)
- **IDE**: VS Code with HashiCorp Terraform extension

## Development Environment

This repository includes a **GitHub Codespaces** configuration (`.devcontainer/`) that provides:
- Pre-installed Terraform, TFLint, and Terragrunt
- Azure CLI for authentication
- Custom welcome message on container startup
- VS Code extensions for Terraform development

## Training Format

Each lab contains:
- `README.md` - Lab instructions and objectives
- `solution/` - Reference implementation
- Expected duration estimates
- Hands-on exercises

## Key Learning Objectives

1. **Infrastructure as Code fundamentals** using Terraform
2. **Azure resource provisioning** and management
3. **State management** including remote backends and locking
4. **Module development** and reusability
5. **Testing strategies** for infrastructure code
6. **Production best practices** and common pitfalls
7. **Refactoring techniques** for existing infrastructure

## Important Notes for Claude

### When Working with This Repository:

1. **Solution Structure**: Each exercise has a `solution/` folder - reference these for correct implementation patterns
2. **Azure Focus**: All examples use Azure provider (`azurerm`)
3. **Progressive Difficulty**: Labs build on previous concepts
4. **State Files**: `.tfstate` files should be in `.gitignore` (check if present)
5. **Provider Versions**: Check `providers.tf` for version constraints

### Common Patterns in This Codebase:

- **Resource Groups**: Most examples create or reference Azure Resource Groups
- **Naming Conventions**: Resources often follow patterns like `<name>-<environment>-<resource-type>`
- **Variables**: Typically defined in `variables.tf` or inline in `main.tf`
- **Backend Configuration**: Remote state examples use Azure Storage

### When Helping with Code Updates:

1. **Check Context**: Determine which Day/Lab the code belongs to
2. **Follow Patterns**: Match existing solution patterns in that section
3. **Azure Resources**: Ensure proper Azure provider configuration
4. **State Considerations**: Be mindful of state implications for changes
5. **Testing**: Suggest validation with `terraform validate` and `terraform plan`

### File Naming Conventions:

- `main.tf` - Primary resource definitions
- `variables.tf` - Variable declarations
- `outputs.tf` - Output definitions
- `providers.tf` - Provider configuration
- `versions.tf` - Version constraints
- `locals.tf` - Local values

## Important: Code Modernization Required

**This codebase is approximately 3 years old and requires updates:**

### Critical Updates Needed:

1. **Terraform Version Updates**
   - Update `required_version` constraints in `versions.tf` files
   - Current code likely uses Terraform ~0.12-0.14, should update to 1.x or latest
   - Review and update syntax for any deprecated features

2. **Provider Version Updates**
   - **Azure Provider (`azurerm`)**: Likely on version 2.x, should update to 3.x or 4.x
   - Check for breaking changes between provider versions
   - Update `required_providers` blocks with current version constraints
   - Review provider configuration for deprecated arguments

3. **Common Breaking Changes to Watch For**
   - Azure provider 3.x introduced breaking changes (e.g., `features` block requirements)
   - Deprecated resource attributes and arguments
   - Changed default behaviors
   - New required fields

4. **Migration Strategy**
   - Check each lab's `versions.tf` and `providers.tf` files
   - Update provider versions incrementally
   - Test with `terraform validate` and `terraform plan`
   - Update documentation to reflect new versions
   - Ensure examples still work with updated providers

### When Updating Code:
- Always check current Terraform and provider versions
- Reference official migration guides for major version updates
- Update version constraints to use current stable versions
- Test thoroughly as provider updates may change resource behavior
- Document any significant changes in behavior

## Current Focus

The user is working on updating code. Check the context of recent file opens to understand:
- Which lab/exercise they're working on
- Whether it's a solution or student attempt
- What specific Terraform concepts are being applied
- **Priority: Modernizing provider and Terraform versions**

## Getting Started (for Claude)

When assisting:
1. Identify the lab/exercise from the file path
2. Review the lab's README for specific requirements
3. Check the solution folder for reference implementation
4. Ensure code follows Terraform best practices
5. Test suggestions with proper Azure resource structure
