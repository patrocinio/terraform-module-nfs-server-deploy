#!/bin/env python
import os, sys, yaml, json, getpass
cf = '/tmp/config.yaml'
ci = '/tmp/items-config.yaml'
co = '/opt/ibm/cluster/config.yaml'

# Load config from config file if provided
if os.stat(cf).st_size == 0:
  config_f = {}
else:
  with open(cf, 'r') as stream:
    try:
        config_f = yaml.load(stream)
    except yaml.YAMLError as exc:
        print(exc)


# Load config items if provided
with open(ci, 'r') as stream:
  config_i = json.load(stream)

# If merging changes, start by loading default values. Else start with empty dict
if len(sys.argv) > 1:
  if sys.argv[1] == "merge":
    with open(co, 'r') as stream:
      try: 
        config_o = yaml.load(stream)
      except yaml.YAMLError as exc:
        print(exc)
  else:
    config_o = {}
    

# First accept any changes from supplied config file
config_o.update(config_f)

# Second accept any changes from supplied config items
config_o.update(config_i)

# Automatically add the ansible_become if it does not exist, and if we are not root
if not 'ansible_user' in config_o and getpass.getuser() != 'root':
  config_o['ansible_user'] = getpass.getuser()
  config_o['ansible_become'] = True

# Write the new configuration
with open(co, 'w') as of:
  yaml.safe_dump(config_o, of, explicit_start=True, default_flow_style = False)
