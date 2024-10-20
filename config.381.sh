#!/bin/bash
ansible-playbook vlan381.ens192.yml -t conf -e user=root -b
