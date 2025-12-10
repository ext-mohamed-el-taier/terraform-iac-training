## Final

For the final part of this lab, you're going to refactor the network security groups into their own module, named `network_security_rules`.

1. Create a new directory named `final/`
1. Copy the `traps/count` directory (and subdirectory) to `final/`.
1. Create a new directory named `final/network_security_rules`. You'll be refactoring all security-related resources into a module under this directory.
1. Refactor the `network_security_rules` module to:
    1. Open ports 80 and 443 on the Web subnet
    1. Open port 8080 on the App subnet
    1. Open port 1433 on the DB subnet
1. Ensure your code can apply, including from scratch into net-new environments!
1. There are multiple ways to get this done - be prepared to demo and explain your solution.

### HINTS
1. Remember you can loop modules with the `for_each` meta-argument
1. Use complex variable types like `object({})` and `map(object({}))` as inputs to your module.
1. Don't be afraid to repurpose existing complex variable types with additional attributes (ahem, `var.subnets`).
