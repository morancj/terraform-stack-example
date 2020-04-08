# `templates` directory

## `user_data.tpl`

This is EC2 [Instance User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-add-user-data.html): it provides sane defaults for new instances. Currently, it:

- Installs all available updates
- Generates new SSH host keys
- Overwrites the hostname files with the FQDN.

The FQDN is determined from the template: if launching a new EC2 Instance from one of these templates, the Tag `Name` and User Data should be updated as required.
