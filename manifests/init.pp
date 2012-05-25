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
#   $module_paths       = $puppet::params::module_paths,
#   $base_module_paths  = $puppet::params::base_module_paths,
#   $puppet_init_config = $puppet::params::puppet_init_config,
#   $puppet_config      = $puppet::params::puppet_config,
#   $puppet_version     = $puppet::params::puppet_version,
#   $vim_puppet_version = $puppet::params::vim_puppet_version
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
class puppet (

  $module_paths       = $puppet::params::module_paths,
  $base_module_paths  = $puppet::params::base_module_paths,
  $puppet_init_config = $puppet::params::puppet_init_config,
  $puppet_config      = $puppet::params::puppet_config,
  $puppet_version     = $puppet::params::puppet_version,
  $vim_puppet_version = $puppet::params::vim_puppet_version

) inherits puppet::params {

  #-----------------------------------------------------------------------------

  if $base_module_paths {
    $all_module_paths = [ $base_module_paths, $module_paths ]
  }
  elsif $module_paths {
    $all_module_paths = $module_paths
  }
  else {
    fail('module paths must be defined')
  }

  #-----------------------------------------------------------------------------
  # Install

  if ! $puppet_version {
    fail('Puppet version must be defined')
  }
  package { 'puppet':
    ensure => $puppet_version,
  }

  if $vim_puppet_version {
    package { 'vim-puppet':
      ensure => $vim_puppet_version,
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

  if $puppet_init_config {
    file { $puppet_init_config:
      owner    => 'root',
      group    => 'root',
      mode     => 644,
      source  => 'puppet:///modules/puppet/puppet_init.conf',
      require => Package['puppet'],
    }
  }

  if $puppet_config {
    file { $puppet_config:
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
    require   => File[$puppet_config],
  }
}
