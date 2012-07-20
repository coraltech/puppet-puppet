
class puppet::params {

  #-----------------------------------------------------------------------------
  # General configurations

  if $::hiera_ready {
    $puppet_package_ensure = hiera('puppet_package_ensure', $puppet::default::puppet_package_ensure)
    $puppet_service_ensure = hiera('puppet_service_ensure', $puppet::default::puppet_service_ensure)
    $vim_puppet_ensure     = hiera('puppet_vim_puppet_ensure', $puppet::default::vim_puppet_ensure)
    $puppet_module_ensure  = hiera('puppet_vim_puppet_ensure', $puppet::default::puppet_module_ensure)
    $manifest_file         = hiera('puppet_manifest_file', $puppet::default::manifest_file)
    $reports               = hiera('puppet_reports', $puppet::default::reports)
    $report_emails         = hiera('puppet_report_emails', $puppet::default::report_emails)
    $update_interval       = hiera('puppet_update_interval', $puppet::default::update_interval)
  }
  else {
    $puppet_package_ensure = $puppet::default::puppet_package_ensure
    $puppet_service_ensure = $puppet::default::puppet_service_ensure
    $vim_puppet_ensure     = $puppet::default::vim_puppet_ensure
    $puppet_module_ensure  = $puppet::default::puppet_module_ensure
    $manifest_file         = $puppet::default::manifest_file
    $reports               = $puppet::default::reports
    $report_emails         = $puppet::default::report_emails
    $update_interval       = $puppet::default::update_interval
  }

  #-----------------------------------------------------------------------------
  # Operating system specific configurations

  case $::operatingsystem {
    debian, ubuntu: {
      $os_puppet_package          = 'puppet'
      $os_puppet_service          = 'puppet'
      $os_vim_puppet_package      = 'vim-puppet'
      $os_puppet_module_package   = 'puppet-module'

      $os_init_config             = '/etc/default/puppet'
      $os_init_config_template    = 'puppet/puppet_init.conf.erb'
      $os_config_dir              = '/etc/puppet'
      $os_config                  = "${os_config_dir}/puppet.conf"
      $os_config_template         = 'puppet/puppet.conf.erb'
      $os_tagmail_config          = "${os_config_dir}/tagmail.conf"
      $os_tagmail_config_template = 'puppet/tagmail.conf.erb'

      $os_template_dir            = "${os_config_dir}/templates"
      $os_manifest_dir            = "${os_config_dir}/manifests"

      $os_module_dirs             = [ "${os_config_dir}/modules" ]

      $os_report_dir              = "/var/log/puppet/reports"

      $os_update_environment      = 'PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin'
      $os_update_command          = "puppet apply '${os_manifest_dir}/${manifest_file}'"
    }
    default: {
      fail("The puppet module is not currently supported on ${::operatingsystem}")
    }
  }
}
