# -*- mode: ruby -*-
# vi: set ft=ruby :

# Copyright (C) 2019 Michael Joseph Walsh - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the the license.
#
# You should have received a copy of the license with
# this file. If not, please email <mjwalsh@nemonik.com>

module AnsibleExtraVars

  # Define extra_vars for Ansible
  ANSIBLE_EXTRA_VARS = {

      ansible_version: '2.9.1',

      default_retries: '60',
      default_delay: '15',

      k3s_version: 'v1.0.1-rc1',
#      k3s_version: 'v1.0.0',
      k3s_flannel_iface: 'eth1',
      k3s_cluster_secret: 'kluster_secret',

      traefik_version: '1.7.20',

      gitlab_version: '12.5.2',
      gitlab_port: '10080',
      gitlab_ssh_port: '10022',
      gitlab_user: 'root',
      gitlab_root_password: "password"

    }

  def AnsibleExtraVars.as_string()
    ansible_extra_vars = ANSIBLE_EXTRA_VARS

    ansible_extra_vars_string = ''

    ansible_extra_vars.each do |key, value|
      if ( ( key == :CA_CERTIFICATES ) && ( !value.nil? ) && value != '' )
        ansible_extra_vars_string = ansible_extra_vars_string + "\\\"#{key}\\\":\\\["
        value.each { |item|
          ansible_extra_vars_string = ansible_extra_vars_string + "\\\"#{item}\\\","
        }
        ansible_extra_vars_string = ansible_extra_vars_string.chop + '\\],'
      else
        ansible_extra_vars_string = ansible_extra_vars_string + "\\\"#{key}\\\":\\\"#{value}\\\","
      end
    end

    return '\\{' + ansible_extra_vars_string.chop + '\\}'
  end
end
