# Cockpit Install

Installs [Cockpit](https://cockpit-project.org/) on linux hosts.

---


## Supports:

* Ubuntu
* Debian
* RedHat
* CentOS

## Usage

### cockpit_install::default

Just include `cockpit_install` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[cockpit_install]"
  ]
}
```

## Attributes

### Action

Define the install action for the package.

Default Value:

* `install`

Valid Options

* `install`
* `upgrade`
* `remove`
* version number - supply a version string to install a specific version.

Ruby usage:

```ruby
node['cockpit_install']['action'] = 'install'
```

JSON usage:

```json
{
  "cockpit_install": {
    "action": "178-1~ubuntu16.04.1"
   }
}
```
