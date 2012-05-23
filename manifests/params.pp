
class puppet::params {

  #-----------------------------------------------------------------------------

  $puppet_init_config = '/etc/default/puppet'
  $puppet_config      = '/etc/puppet/puppet.conf'

  $base_module_paths  = [ '/etc/puppet/modules' ]

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
