# Common Traps

## Expected Outcome
You will review and understand some of the most common traps or mistakes made in Terraform codebases. These are synthetic traps, however, the lessons should prove valuable in realworld scenarios.

## How To

We're going to leverage the existing codebase we wrote during the [201-functions lab](../../Day2/201-functions). If you weren't here for that lab, please go back and review that codebase solution before beginning this lab.

## Code that Can't Be Deployed from Scratch
One of the most common issues we've seen with teams who use Terraform is problems that arise when taking a mature Terraform codebase and attempt to deploy it into a net-new environment. It works in an existing environment, which is not treated as immutable, but rather has been added to, bit-by-bit, over time.

This issue is typically caused by two things:
    1. Terraform is written and deployed incrementally against one or more environments, but not regularly deployed from scratch, a.k.a. mutable, incremental, and not deployed atomically.
    1. Dependencies amongst different Terraform resources are assumed to be "good" based on Terraform's [implicit dependency tree](https://www.terraform.io/language/resources/behavior#resource-dependencies)

Let's examine how this may occur.

Open [the traps/scratch directory README.md](./traps/scratch/README.md) to continue.

## Unexpected Changes Caused by Count Loops
Using loops in Terraform is a great way to reduce the number of resource and module blocks you have to define in your codebase, but often comes at the expense of readability, especially to users new to Terraform.

There are two meta-arguments that can be used to define a loop: `count`, which has been around longer of the two and `for_each`. You're likely to encounter both if not use them in your own codebases.

When choosing one of these meta-arguments for your own loops, you must be aware of the caveats.

Let's examine how resources defined using `count` loops can lead to unexpected changes and why.

Open [the traps/count directory README.md](./traps/count/README.md) to continue.

## Final

For the final part of this lab, you're going to refactor the network security groups into their own module, named `network_security_rules`.

1. Create a new directory named `final/`
1. Copy the `traps/count` directory (and subdirectory) to `final/`.
1. Create a new directory named `final/network_security_rules`. You'll be refactoring all security-related resources into a module under this directory.
1. Without changing the `vnet` or `subnets` that are passed into the `network` module, refactor the `network_security_rules` module to:
    1. Open ports 80 and 443 on the Web subnet
    1. Open port 8080 on the App subnet
    1. Open port 1433 on the DB subnet
1. Ensure your code can apply, including from scratch into net-new environments!
1. There are multiple ways to get this done - be prepared to demo and explain your solution.

### HINTS
1. Remember you can loop modules with the `for_each` meta-argument
1. Use complex variable types like `object({})` and `map(object({}))` as inputs to your module.
1. Don't be afraid to repurpose existing complex variable types with additional attributes (ahem, `var.subnets`).
