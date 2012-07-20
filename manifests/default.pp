
class puppet::default {
  $puppet_package_ensure = 'present'
  $puppet_service_ensure = 'stopped'
  $vim_puppet_ensure     = 'present'
  $puppet_module_ensure  = 'present'
  $manifest_file         = 'site.pp'
  $reports               = [ 'log', 'store' ]
  $report_emails         = {}
  $update_interval       = 30  # Minutes
}
