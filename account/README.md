# `account` directory

This top-level directory is for config specific to an AWS Account. It's called directly from [../main.tf](../main.tf).

Defaults should be used when possible: variables must only be specified when overriding a module's defaults is required.

As [dev](dev) doesn't (yet) deviate from the defaults (it is a sandbox account: the defaults should therefore be configured for this account), it is a soft link to [default](default). [common](common) exists for consistency with [../environment/common](../environment/common), which should be renamed in future to [../environment/default](../environment/default). At that point, the [common] symlink here should be removed.
