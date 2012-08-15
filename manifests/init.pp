# Class: puppet
#
#   This module manages the Puppet service.
#
#   Adrian Webb <adrian.webb@coraltech.net>
#   2012-05-22
#
#   Tested platforms:
#    - Ubuntu 12.04
#
# Parameters: (see example/params.json> for Hiera configurations)
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

  $package                 = $puppet::params::package,
  $package_ensure          = $puppet::params::package_ensure,
  $service                 = $puppet::params::service,
  $service_ensure          = $puppet::params::service_ensure,
  $vim_puppet_package      = $puppet::params::vim_puppet_package,
  $vim_puppet_ensure       = $puppet::params::vim_puppet_ensure,
  $puppet_module_package   = $puppet::params::puppet_module_package,
  $puppet_module_ensure    = $puppet::params::puppet_module_ensure,
  $init_config             = $puppet::params::init_config,
  $init_config_template    = $puppet::params::init_config_template,
  $config_dir              = $puppet::params::config_dir,
  $config_template         = $puppet::params::config_template,
  $config                  = $puppet::params::config,
  $tagmail_config          = $puppet::params::tagmail_config,
  $tagmail_config_template = $puppet::params::tagmail_config_template,
  $template_dir            = $puppet::params::template_dir,
  $manifest_dir            = $puppet::params::manifest_dir,
  $manifest_file           = $puppet::params::manifest_file,
  $module_dirs             = $puppet::params::module_dirs,
  $report_dir              = $puppet::params::report_dir,
  $reports                 = $puppet::params::reports,
  $report_emails           = $puppet::params::report_emails,
  $update_environment      = $puppet::params::update_environment,
  $update_command          = $puppet::params::update_command,
  $update_interval         = $puppet::params::update_interval,


) inherits puppet::params {

  #-----------------------------------------------------------------------------
  # Install

  if empty($module_dirs) {
    fail('Puppet module paths must be defined')
  }

  if ! ($package and $package_ensure) {
    fail('Puppet package name and ensure value must be defined')
  }
  package { 'puppet':
    name   => $package,
    ensure => $package_ensure,
  }

  if $vim_puppet_package and $vim_puppet_ensure {
    package { 'vim-puppet':
      name    => $vim_puppet_package,
      ensure  => $vim_puppet_ensure,
      require => Package['puppet'],
    }
  }

  #---

  if $puppet_module_package and $puppet_module_ensure {
    package { 'puppet-module':
      name     => $puppet_module_package,
      ensure   => $puppet_module_ensure,
      provider => 'gem',
      require  => Package['puppet'],
    }
  }

  #-----------------------------------------------------------------------------
  # Configure

  if $init_config {
    file { $init_config:
      content => template($init_config_template),
      require => Package['puppet'],
      notify  => Service['puppet'],
    }
  }

  if $config {
    file { $config:
      content => template($config_template),
      require => Package['puppet'],
      notify  => Service['puppet'],
    }
  }

  if $tagmail_config {
    file { $tagmail_config:
      content => template($tagmail_config_template),
      require => Package['puppet'],
      notify  => Service['puppet'],
    }
  }

  file { $report_dir:
    ensure  => directory,
    require => Package['puppet'],
  }

  #-----------------------------------------------------------------------------
  # Manage

  service { 'puppet':
    name   => $service,
    ensure => $service_ensure,
  }

  if $service_ensure == 'stopped' {
    cron { 'puppet-cron':
      ensure => $update_command ? {
        ''      => 'absent',
        default => 'present',
      },
      environment => $update_environment,
      command     => $update_command,
      user        => 'root',
      minute      => "*/${update_interval}",
    }
  }
}
