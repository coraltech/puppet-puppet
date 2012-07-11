
class puppet::params {

  #-----------------------------------------------------------------------------

  $puppet_init_config    = '/etc/default/puppet'

  $puppet_path           = '/etc/puppet'
  $puppet_config         = "${puppet_path}/puppet.conf"
  $puppet_tagmail_config = "${puppet_path}/tagmail.conf"

  $hiera_config          = "/etc/hiera.yaml"
  $hiera_puppet_config   = "${puppet_path}/hiera.yaml"

  $template_path         = "${puppet_path}/templates"
  $manifest_path         = "${puppet_path}/manifests"
  $manifest_file         = 'site.pp'

  $base_module_paths     = [ "${puppet_path}/modules" ]

  if $::vagrant_exists {
    $reports = "store"
  }
  else {
    $reports = "log,store"
  }

  $report_path           = "/var/log/puppet/reports"
  $report_emails         = {}

  $update_interval       = 30  # Minutes
  $update_environment    = 'PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
  $update_command        = "puppet apply '${manifest_path}/${manifest_file}'"

  $hiera_hierarchy       = [ '%{environment}', '%{hostname}', 'common' ]
  $hiera_backends        = [
    {
      'type'    => 'json',
      'datadir' => '/var/lib/hiera',
    },
    {
      'type'       => 'puppet',
      'datasource' => 'data',
    },
  ]

  $hiera_puppet_gem      = '/tmp/hiera-puppet.gem'

  case $::operatingsystem {
    debian: {}
    ubuntu: {
      $puppet_version     = '2.7.11-1ubuntu2'
      $vim_puppet_version = '2.7.11-1ubuntu2'
    }
    centos: {}
    redhat: {}
  }
}
