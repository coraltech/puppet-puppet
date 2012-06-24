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
#   $module_paths       = [ ],
#   $hiera_hierarchy    = $puppet::params::hiera_hierarchy,
#   $hiera_backends     = $puppet::params::hiera_backends,
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

  $module_paths       = [ ],
  $hiera_hierarchy    = $puppet::params::hiera_hierarchy,
  $hiera_backends     = $puppet::params::hiera_backends,
  $puppet_version     = $puppet::params::puppet_version,
  $vim_puppet_version = $puppet::params::vim_puppet_version

) inherits puppet::params {

  #-----------------------------------------------------------------------------

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

  package { [ 'puppet-module', 'hiera', 'hiera-puppet', 'hiera-json' ]:
    ensure    => 'present',
    provider  => 'gem',
    subscribe => Package['puppet'],
  }

  #-----------------------------------------------------------------------------
  # Configure

  if $puppet::params::puppet_init_config {
    file { $puppet::params::puppet_init_config:
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      source  => 'puppet:///modules/puppet/puppet_init.conf',
      require => Package['puppet'],
      notify  => Service['puppet'],
    }
  }

  if $puppet::params::puppet_config {
    file { $puppet::params::puppet_config:
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      content => template('puppet/puppet.conf.erb'),
      require => Package['puppet'],
      notify  => Service['puppet'],
    }
  }

  if $puppet::params::hiera_config {
    file { $puppet::params::hiera_config:
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      content => template('puppet/hiera.yaml.erb'),
      require => Package['hiera'],
      notify  => Service['puppet'],
    }
  }

  #-----------------------------------------------------------------------------
  # Manage

  service { 'puppet':
    enable  => true,
    ensure  => running,
    require => File[$puppet::params::puppet_config],
  }
}
