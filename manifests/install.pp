# Private class.
class openondemand::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  ensure_packages($openondemand::scl_packages)

  # Assumes /var/www - must create since httpd24 does not
  $_web_directory_parent = dirname($openondemand::_ood_web_directory)
  if ! defined(File[$_web_directory_parent]) {
    file { $_web_directory_parent:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  if ! defined(File[$openondemand::_ood_web_directory]) {
    file { $openondemand::_ood_web_directory:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  file { '/opt/ood':
    ensure => 'directory',
  }
  file { '/opt/ood/src':
    ensure => 'directory',
  }

  openondemand::install::component { 'mod_ood_proxy':
    ensure   => $openondemand::_mod_ood_proxy_ensure,
    revision => $openondemand::mod_ood_proxy_revision,
  }

  openondemand::install::component { 'nginx_stage':
    ensure   => $openondemand::_nginx_stage_ensure,
    revision => $openondemand::nginx_stage_revision,
  }

  openondemand::install::component { 'ood_auth_map':
    ensure   => $openondemand::_ood_auth_map_ensure,
    revision => $openondemand::ood_auth_map_revision,
  }

  openondemand::install::component { 'ood_auth_discovery':
    ensure         => $openondemand::_ood_auth_discovery_ensure,
    path           => $openondemand::ood_auth_discover_root,
    revision       => $openondemand::ood_auth_discovery_revision,
    install_method => 'none',
  }

  openondemand::install::component { 'ood_auth_registration':
    ensure         => $openondemand::_ood_auth_registration_ensure,
    path           => $openondemand::ood_auth_register_root,
    revision       => $openondemand::ood_auth_registration_revision,
    install_method => 'none',
  }

}