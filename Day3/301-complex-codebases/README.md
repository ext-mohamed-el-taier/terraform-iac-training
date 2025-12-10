# Complex Codebases

## Expected Outcome
You will review a portion of a Terraform codebase that was pulled from a working environment (decommissioned) to learn about real-world practies (both good and bad), how to quickly and effectively read a mature codebase you're not familiar with to gain understanding, and how to contribute.

## How To
The Terraform code in this lab was pulled from a working Azure environment that is now decommissioned. Identifying names have been redacted.

This code is a small snippet of a much larger codebase that was versioned and deployed using Azure DevOps Repos and YAML Pipelines. This small snippet focuses on the "core" IaC that was used to configure and secure 2 geo-replicated Azure Kubernetes Service (AKS) clusters. Because this is only a snippet, the code is incomplete and cannot be deployed on its own.

> Note: this codebase was built against Terraform v0.12.x, which is well-aged at this point and contains some differences in syntax and style as well as lacks many features that have been present in the HashiCorp Config Language (HCL) for some time now.

### High-Level Review
1. Open the `example/` directory to see the codebase. What do you see first?
1. Open the README.md and read the first section - what do you notice about how the documentation is organized? How might this be helpful to contributors?
1. Open the CHANGELOG.md and review a few lines. How can a CHANGELOG help you troubleshoot problems? What about in light of the "common traps" you learned about?
1. What do you notice about the versioning numbers? If you had to guess, how do you think the team chose to increment their major, minor, and patch versions? What are some _different_ strategies for versioning with Semantic Versioning?

### Digging in
1. Open `example/core/`. Notice how the Terraform codebase is broken up into several files. What are the advantages and disadvantages of doing it this way?
1. Which .tf file are you drawn to first and why? How might this influence your decision to name your .tf files?
1. Review each of the .tf files in the `example/core/` directory. What do you notice about the organization of resources, variables, outputs, and configuration?
1. Can you find potential issue with terraform version pinning? **NOTE** this codebase was written in Terraform v0.12, which has different syntax for provider versions that we've used during this training. The [terraform upgrade guides](https://www.terraform.io/language/upgrade-guides/0-13) are very helpful for understanding the differences amongst several versions of Terraform.
1. How are [provider aliases](https://www.terraform.io/language/providers/configuration#alias-multiple-provider-configurations) used in `main.tf`? You'll want to look at `providers.tf` to see how the providers are defined, then look at the Kubernetes "k8s" module blocks in `main.tf`.
1. Why do you think the provider aliases were used this way? Do you think these providers will work on a net-new environment? Why or why not?
1. Name 3 inconsistencies you see in `example/core/inputs.tf`. How would you change these?

### Kubernetes Module
1. Open `example/core/modules/k8s_config/` and take a moment to review the .tf files. All paths in this section are relative to this directory (so "chroot" your mind!).
1. If you were asked to provide a `providers.tf` in this repository, how would you define it? What are the potential problems with version pinning using the `=` or `~>` (pessimistic constraint) operators?
1. Look at line 55 of `mod_locals.tf`. What does this expression produce?
    1. Look at the `azurerm_role_assignment` block starting on line 14 in `legacy.tf`. How is the `local.legacy_aks_roles["user"]` used? Why do you think it was done this way?
1. This codebase was in the process of being refactored when the project was shutdown at the beginning of the Coronavirus pandemic. Some of the k8s code was refactored and the "old" code moved into the `legacy.tf` file. The intent was that this code would eventually be deleted. What's an advantage to organizing the code this way?
    1. What is the implication in the statefile when moving resources from one .tf file to another?
1. Find 4 examples of a git-sourced Terraform module being reused in `legacy.tf`.
    1. How are git-sourced modules versioned?
    1. Unforunately, I don't have the source code for `tf_k8s_tiller`, but can you guess what the default value for the `is_cluster_role` variable is in the module? Why?
1. Look at local.namespaces on line 74 in `mod_locals.tf`.
    1. Where is `var.products` defined?
    1. How and where is `local.namespaces` used in `main.tf`?
    1. How could `var.products` benefit from a strongly typed variable of type `map(object({}))`? How would this make reading and contributing to the Terraform easier?
1. How many module calls are there to the namespace module in `main.tf`?
    1. Terraform 0.12 didn't support the `for_each` meta-argument on modules. How would that have been helpful here?

### Outputs
1. How are outputs "bubbled up" from the various modules in `example/core/modules` to the Terraform in `example/core`?
1. What are some [additional properties](https://www.terraform.io/language/values/outputs#optional-arguments) of the output identifier that you could add to `example/core/output.tf`? Why?
