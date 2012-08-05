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

  $package                 = $puppet::params::os_puppet_package,
  $package_ensure          = $puppet::params::puppet_package_ensure,
  $service                 = $puppet::params::os_puppet_service,
  $service_ensure          = $puppet::params::puppet_service_ensure,
  $vim_puppet_package      = $puppet::params::os_vim_puppet_package,
  $vim_puppet_ensure       = $puppet::params::vim_puppet_ensure,
  $puppet_module_package   = $puppet::params::os_puppet_module_package,
  $puppet_module_ensure    = $puppet::params::puppet_module_ensure,
  $init_config             = $puppet::params::os_init_config,
  $config_dir              = $puppet::params::os_config_dir,
  $config                  = $puppet::params::os_config,
  $tagmail_config          = $puppet::params::os_tagmail_config,
  $template_dir            = $puppet::params::os_template_dir,
  $manifest_dir            = $puppet::params::os_manifest_dir,
  $manifest_file           = $puppet::params::manifest_file,
  $module_dirs             = $puppet::params::os_module_dirs,
  $report_dir              = $puppet::params::os_report_dir,
  $reports                 = $puppet::params::reports,
  $report_emails           = $puppet::params::report_emails,
  $update_environment      = $puppet::params::os_update_environment,
  $update_command          = $puppet::params::os_update_command,
  $update_interval         = $puppet::params::update_interval,
  $init_config_template    = $puppet::params::os_init_config_template,
  $config_template         = $puppet::params::os_config_template,
  $tagmail_config_template = $puppet::params::os_tagmail_config_template,

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
      name   => $vim_puppet_package,
      ensure => $vim_puppet_ensure,
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
