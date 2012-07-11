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
#   $manifest_path      = $puppet::params::manifest_path,
#   $manifest_file      = $puppet::params::manifest_file,
#   $module_paths       = [],
#   $template_path      = $puppet::params::template_path,
#   $update_interval    = $puppet::params::update_interval,
#   $update_environment = $puppet::params::update_environment,
#   $update_command     = $puppet::params::update_command,
#   $hiera_hierarchy    = $puppet::params::hiera_hierarchy,
#   $hiera_backends     = $puppet::params::hiera_backends,
#   $puppet_version     = $puppet::params::puppet_version,
#   $vim_puppet_version = $puppet::params::vim_puppet_version,
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

  $manifest_path      = $puppet::params::manifest_path,
  $manifest_file      = $puppet::params::manifest_file,
  $module_paths       = [],
  $template_path      = $puppet::params::template_path,
  $update_interval    = $puppet::params::update_interval,
  $update_environment = $puppet::params::update_environment,
  $update_command     = $puppet::params::update_command,
  $reports            = $puppet::params::reports,
  $report_path        = $puppet::params::report_path,
  $report_emails      = $puppet::params::report_emails,
  $hiera_hierarchy    = $puppet::params::hiera_hierarchy,
  $hiera_backends     = $puppet::params::hiera_backends,
  $puppet_version     = $puppet::params::puppet_version,
  $vim_puppet_version = $puppet::params::vim_puppet_version,

) inherits puppet::params {

  $tagmail_config   = $puppet::params::puppet_tagmail_config

  $hiera_puppet_gem = $puppet::params::hiera_puppet_gem

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

  package { 'puppet-module':
    ensure    => 'present',
    provider  => 'gem',
    subscribe => [ Class['ruby'], Package['puppet'] ],
  }

  /*package { 'hiera-puppet':
    ensure    => 'present',
    provider  => 'gem',
    subscribe => [ Class['ruby'], Package['hiera'], Package['puppet'] ],
  }*/

  file { 'hiera-puppet-gem':
    path      => $hiera_puppet_gem,
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => 644,
    source    => 'puppet:///modules/puppet/hiera-puppet-1.0.0rc1.20.gem',
    subscribe => [ Class['ruby'], Package['hiera'], Package['puppet'] ],
  }

  exec { 'install-hiera-puppet-gem':
    path        => [ '/bin', '/usr/bin' ],
    command     => "gem install --local '${hiera_puppet_gem}'",
    refreshonly => true,
    subscribe   => File['hiera-puppet-gem'],
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

  if $tagmail_config {
    file { $tagmail_config:
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      content => template('puppet/tagmail.conf.erb'),
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

  if $puppet::params::hiera_puppet_config {
    file { $puppet::params::hiera_puppet_config:
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      content => template('puppet/hiera.puppet.yaml.erb'),
      require => Package['hiera'],
      notify  => Service['puppet'],
    }
  }

  file { $report_path:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    require => Package['puppet'],
  }

  #-----------------------------------------------------------------------------
  # Manage

  # No puppet agent!  We self manage with "puppet apply".
  service { 'puppet':
    ensure  => 'stopped',
  }

  cron { 'puppet-cron':
    ensure      => 'present',
    environment => $update_environment,
    command     => $update_command,
    user        => 'root',
    minute      => "*/${update_interval}",
  }
}
