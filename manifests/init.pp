# Class: puppet
#
#   This module manages the Puppet service.
#
#   Adrian Webb <adrian.webb@coraltg.com>
#   2012-05-22
#
#   Tested platforms:
#    - Ubuntu 12.04
#
# Parameters:
#
#   $module_paths = [ ]
#
# Actions:
#
#  Installs, configures, and manages the Puppet service.
#
# Requires:
#
# Sample Usage:
#
#   class { 'puppet':
#     module_paths => [ "/usr/local/share/puppet/modules" ]
#   }
#
# [Remember: No empty lines between comments and class definition]
class puppet ( $module_paths = [ ] ) {

  include puppet::params

  if $puppet::params::base_module_paths {
    $all_module_paths = [ $puppet::params::base_module_paths, $module_paths ]
  }
  elsif $module_paths {
    $all_module_paths = $module_paths
  }
  else {
    fail('module paths must be defined')
  }

  #-----------------------------------------------------------------------------
  # Install

  if ! $puppet::params::puppet_version {
    fail('Puppet version must be defined')
  }
  package { 'puppet':
    ensure => $puppet::params::puppet_version,
  }

  if $puppet::params::vim_puppet_version {
    package { 'vim-puppet':
      ensure => $puppet::params::vim_puppet_version,
    }
  }

  #---

  package { 'puppet-module':
    ensure    => 'present',
    provider  => 'gem',
    subscribe => Package['puppet'],
  }

  #-----------------------------------------------------------------------------
  # Configure

  if $puppet::params::puppet_init_config {
    file { $puppet::params::puppet_init_config:
      owner    => 'root',
      group    => 'root',
      mode     => 644,
      source  => 'puppet:///modules/puppet/puppet_init.conf',
      require => Package['puppet'],
    }
  }

  if $puppet::params::puppet_config {
    file { $puppet::params::puppet_config:
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      content => template('puppet/puppet.conf.erb'),
      require => Package['puppet'],
    }
  }

  #-----------------------------------------------------------------------------
  # Manage

  service { 'puppet':
    enable    => true,
    ensure    => running,
    subscribe => Package['puppet'],
  }
}
