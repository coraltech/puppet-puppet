
class puppet::default {

  $package_ensure        = 'present'
  $service_ensure        = 'stopped'
  $vim_puppet_ensure     = 'present'
  $puppet_module_ensure  = 'present'

  $manifest_file         = 'site.pp'
  $reports               = [ 'store' ]

  $report_emails         = {}

  $update_interval       = 30  # Minutes

  #---

  case $::operatingsystem {
    debian, ubuntu: {
      $package                 = 'puppet'
      $service                 = 'puppet'
      $vim_puppet_package      = 'vim-puppet'
      $puppet_module_package   = 'puppet-module'

      $bin                     = "/usr/bin/puppet"

      $init_config             = '/etc/default/puppet'
      $init_config_template    = 'puppet/puppet_init.conf.erb'
      $config_dir              = '/etc/puppet'
      $config                  = "${config_dir}/puppet.conf"
      $config_template         = 'puppet/puppet.conf.erb'
      $tagmail_config          = "${config_dir}/tagmail.conf"
      $tagmail_config_template = 'puppet/tagmail.conf.erb'

      $template_dir            = "${config_dir}/templates"
      $manifest_dir            = "${config_dir}/manifests"

      $module_dirs             = [ "${config_dir}/modules" ]

      $report_dir              = "/var/log/puppet/reports"

      $update_environment      = 'PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin'
      $update_command          = "${bin} apply '${manifest_dir}/${manifest_file}'"
    }
    default: {
      fail("The puppet module is not currently supported on ${::operatingsystem}")
    }
  }
}
