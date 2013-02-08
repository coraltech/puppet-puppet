
class puppet::params inherits puppet::default {

  $package                 = module_param('package')
  $package_ensure          = module_param('package_ensure')
  $service                 = module_param('service')
  $service_ensure          = module_param('service_ensure')
  $vim_puppet_package      = module_param('vim_puppet_package')
  $vim_puppet_ensure       = module_param('vim_puppet_ensure')
  $puppet_module_package   = module_param('puppet_module_package')
  $puppet_module_ensure    = module_param('puppet_module_ensure')

  #---

  $bin                     = module_param('bin')

  $init_config             = module_param('init_config')
  $init_config_template    = module_param('init_config_template')
  $config_dir              = module_param('config_dir')
  $config                  = module_param('config')
  $config_template         = module_param('config_template')
  $tagmail_config          = module_param('tagmail_config')
  $tagmail_config_template = module_param('tagmail_config_template')

  #---

  $template_dir            = module_param('template_dir')
  $manifest_dir            = module_param('manifest_dir')
  $manifest_file           = module_param('manifest_file')
  $module_dirs             = module_array('module_dirs')

  $report_dir              = module_param('report_dir')
  $reports                 = module_array('reports')
  $report_emails           = module_hash('report_emails')

  $use_cron                = module_param('use_cron')
  $cron_hour               = module_param('cron_hour')
  $cron_minute             = module_param('cron_minute')
  $cron_month              = module_param('cron_month')
  $cron_monthday           = module_param('cron_monthday')
  $cron_weekday            = module_param('cron_weekday')

  $update_environment      = module_param('update_environment')
  $update_command          = module_param('update_command')
}
