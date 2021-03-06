---
title: "Uninstalling Metrics Stack"
date:
draft: false
weight: 41
---

# Uninstalling the Metrics Stack

The following assumes the proper [prerequisites are satisfied][ansible-prerequisites]
we can now uninstall the PostgreSQL Operator Metrics Infrastructure.

First, it is recommended to use the playbooks tagged with the same version
of the Metrics stack currently deployed.

With the correct playbooks acquired and prerequisites satisfied, simply run
the following command:

```bash
ansible-playbook -i /path/to/inventory --tags=uninstall-metrics main.yml
```

If the Crunchy PostgreSQL Operator playbooks were installed using `yum`, use the
following commands:

```bash
export ANSIBLE_ROLES_PATH=/usr/share/ansible/roles/crunchydata

ansible-playbook -i /path/to/inventory --tags=uninstall-metrics \
    /usr/share/ansible/postgres-operator/playbooks/main.yml
```

[ansible-prerequisites]: {{< relref "/installation/other/ansible/prerequisites.md" >}}
