
class puppet::params {

  #-----------------------------------------------------------------------------

  $puppet_init_config = '/etc/default/puppet'
  $puppet_config      = '/etc/puppet/puppet.conf'

  $hiera_config       = '/etc/hiera.yaml'

  $base_module_paths  = [ '/etc/puppet/modules' ]

  $hiera_hierarchy    = [ '%{environment}', 'common' ]
  $hiera_backends     = {
    'yaml' => '/var/lib/hiera',
  }

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
