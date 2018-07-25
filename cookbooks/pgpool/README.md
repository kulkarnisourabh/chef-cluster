pgpool Cookbook
========================
Installs and configures PGPool

Attributes
----------
#### pgpool::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['pgpool']['pgconf']['listen_address']</tt></td>
    <td>String</td>
    <td>listen address</td>
    <td><tt>localhost</tt></td>
  </tr>
  <tr>
    <td><tt>['pgpool']['pgconf']['port']</tt></td>
    <td>String</td>
    <td>bind port</td>
    <td><tt>9999</tt></td>
  </tr>
  <tr>
    <td><tt>['pgpool']['pgconf']['logdir']</tt></td>
    <td>String</td>
    <td>log directory</td>
    <td><tt>/var/log/pgpool</tt></td>
  </tr>
</table>

Usage
-----
#### pgpool::default
Just include `pgpool` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[pgpool]"
  ]
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Jens Jorritsma(jens.jorritsma@rackspace.com)
