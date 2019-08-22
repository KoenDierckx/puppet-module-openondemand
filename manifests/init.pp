# @summary Manage Open OnDemand
#
# @param repo_release
# @param repo_baseurl_prefix
# @param repo_gpgkey
# @param manage_scl
# @param manage_epel
# @param ondemand_package_ensure
# @param ood_auth_discovery_ensure
# @param ood_auth_registration_ensure
# @param mod_auth_openidc_ensure
# @param install_apps
# @param declare_apache
# @param cilogon_client_id
# @param cilogon_client_secret
# @param oidc_crypto_passphrase
# @param listen_addr_port
# @param servername
# @param ssl
# @param logroot
# @param lua_root
# @param lua_log_level
# @param user_map_cmd
# @param user_env
# @param map_fail_uri
# @param auth_type
# @param auth_configs
# @param root_uri
# @param analytics
# @param public_uri
# @param public_root
# @param logout_uri
# @param logout_redirect
# @param host_regex
# @param node_uri
# @param rnode_uri
# @param nginx_uri
# @param pun_uri
# @param pun_socket_root
# @param pun_max_retries
# @param nginx_log_group
# @param oidc_uri
# @param oidc_discover_uri
# @param oidc_discover_root
# @param oidc_provider
# @param oidc_provider_token_endpoint_auth
# @param oidc_provider_scope
# @param oidc_provider_client_id
# @param oidc_provider_client_secret
# @param oidc_remote_user_claim
# @param register_uri
# @param register_root
# @param basic_auth_users
# @param nginx_stage_ondemand_portal
# @param nginx_stage_ondemand_title
# @param nginx_stage_app_root
# @param nginx_stage_scl_env
# @param nginx_stage_app_request_regex
# @param clusters
# @param clusters_hiera_hash
# @param develop_root_dir
# @param usr_apps
# @param usr_app_defaults
# @param dev_apps
# @param dev_app_users
# @param dev_app_defaults
# @param manage_apps_config
# @param apps_config_repo
# @param apps_config_revision
# @param apps_config_repo_path
# @param locales_config_repo_path
# @param apps_config_source
# @param apps_config_target
# @param public_files_repo_paths
#
class openondemand (
  String $repo_release = 'latest',
  Variant[Stdlib::HTTPSUrl, Stdlib::HTTPUrl]
    $repo_baseurl_prefix = 'https://yum.osc.edu/ondemand',
  Variant[Stdlib::HTTPSUrl, Stdlib::HTTPUrl, Stdlib::Absolutepath]
    $repo_gpgkey = 'https://yum.osc.edu/ondemand/RPM-GPG-KEY-ondemand',
  Boolean $manage_scl = true,
  Boolean $manage_epel = true,

  String $ondemand_package_ensure                 = 'present',
  String $ood_auth_discovery_ensure               = 'present',
  String $ood_auth_registration_ensure            = 'present',
  String $mod_auth_openidc_ensure                 = 'present',
  Hash $install_apps                              = {},

  # Apache
  Boolean $declare_apache = true,

  String $cilogon_client_id      = '',
  String $cilogon_client_secret  = '',
  String $oidc_crypto_passphrase  = 'CHANGEME',

  #
  Variant[Array, String, Undef] $listen_addr_port = undef,
  Optional[String] $servername = undef,
  Optional[Array] $ssl = undef,
  String  $logroot = 'logs',
  String $lua_root = '/opt/ood/mod_ood_proxy/lib',
  Optional[String] $lua_log_level = undef,
  String $user_map_cmd  = '/opt/ood/ood_auth_map/bin/ood_auth_map.regex',
  Optional[String] $user_env = undef,
  Optional[String] $map_fail_uri = undef,
  Enum['cilogon', 'openid-connect', 'shibboleth', 'ldap', 'basic'] $auth_type = 'basic',
  Optional[Array] $auth_configs = $openondemand::params::auth_configs,

  String $root_uri = '/pun/sys/dashboard',

  Optional[Struct[{url => String, id => String}]] $analytics = undef,

  String $public_uri = '/public',
  String $public_root = '/var/www/ood/public',

  String $logout_uri = '/logout',
  String $logout_redirect = '/pun/sys/dashboard/logout',

  String $host_regex = '[^/]+',
  Optional[String] $node_uri = undef,
  Optional[String] $rnode_uri = undef,

  String $nginx_uri = '/nginx',
  String $pun_uri = '/pun',
  String $pun_socket_root = '/var/run/ondemand-nginx',
  Integer $pun_max_retries = 5,

  String $nginx_log_group = 'ondemand-nginx',

  Optional[String] $oidc_uri = undef,
  Optional[String] $oidc_discover_uri = undef,
  Optional[String] $oidc_discover_root = undef,
  Optional[String] $oidc_provider = undef,
  Optional[String] $oidc_provider_token_endpoint_auth = undef,
  String $oidc_provider_scope = 'openid email',
  String $oidc_provider_client_id = '',
  String $oidc_provider_client_secret = '',
  Optional[String] $oidc_remote_user_claim = undef,

  Optional[String] $register_uri = undef,
  Optional[String] $register_root = undef,

  Hash $basic_auth_users  = $openondemand::params::basic_auth_users,

  String $nginx_stage_ondemand_portal = 'ondemand',
  String $nginx_stage_ondemand_title  = 'Open OnDemand',
  Openondemand::Nginx_stage_namespace_config $nginx_stage_app_root  = $openondemand::params::nginx_stage_app_root,
  String $nginx_stage_scl_env = 'ondemand',
  Optional[Openondemand::Nginx_stage_namespace_config] $nginx_stage_app_request_regex = undef,

  Hash $clusters = {},
  Boolean $clusters_hiera_hash = true,

  Optional[String] $develop_root_dir = undef,
  Variant[Array, Hash] $usr_apps  = {},
  Hash $usr_app_defaults = {},
  Hash $dev_apps = {},
  Array $dev_app_users = [],
  Hash $dev_app_defaults = {},

  Boolean $manage_apps_config = true,
  Optional[String] $apps_config_repo = undef,
  Optional[String] $apps_config_revision = undef,
  String $apps_config_repo_path = '',
  String $locales_config_repo_path = '',
  Optional[String] $apps_config_source = undef,
  Optional[Stdlib::Absolutepath] $apps_config_target = undef,
  Optional[Array] $public_files_repo_paths = undef,
) inherits openondemand::params {

  $_web_directory = dirname($public_root)

  if $ssl {
    $port = '443'
    $listen_ports = ['443', '80']
  } else {
    $port = '80'
    $listen_ports = ['80']
  }

  $nginx_stage_cmd = '/opt/ood/nginx_stage/sbin/nginx_stage'
  $pun_stage_cmd = "sudo ${nginx_stage_cmd}"

  case $auth_type {
    'ldap': {
      $auth = ['AuthType basic'] + $auth_configs
    }
    'cilogon': {
      $auth = ['AuthType openid-connect'] + $auth_configs
    }
    # Applies to basic, shibboleth, and openid-connect
    default: {
      $auth = ["AuthType ${auth_type}"] + $auth_configs
    }
  }

  if $clusters_hiera_hash {
    $_clusters = lookup('openondemand::clusters', Hash, 'deep', {})
  } else {
    $_clusters = $clusters
  }

  if $develop_root_dir {
    $_develop_mode = true
    $_sys_ensure = 'link'
    $_sys_target = "${develop_root_dir}/sys"
    $_public_ensure = 'link'
    $_public_target = "${develop_root_dir}/public"
    $_discover_target = "${develop_root_dir}/discover"
    $_register_target = "${develop_root_dir}/register"
  } else {
    $_develop_mode = false
    $_sys_ensure = 'directory'
    $_sys_target = undef
    $_public_ensure = 'directory'
    $_public_target = undef
    $_discover_target = undef
    $_register_target = undef
  }

  $ood_portal_config = delete_undef_values({
    'listen_addr_port'    => $listen_ports,
    'servername'          => $servername,
    'port'                => $port,
    'ssl'                 => $ssl,
    'logroot'             => $logroot,
    'lua_root'            => $lua_root,
    'lua_log_level'       => $lua_log_level,
    'user_map_cmd'        => $user_map_cmd,
    'user_env'            => $user_env,
    'map_fail_uri'        => $map_fail_uri,
    'pun_stage_cmd'       => $pun_stage_cmd,
    'auth'                => $auth,
    'root_uri'            => $root_uri,
    'analytics'           => $analytics,
    'public_uri'          => $public_uri,
    'public_root'         => $public_root,
    'logout_uri'          => $logout_uri,
    'logout_redirect'     => $logout_redirect,
    'host_regex'          => $host_regex,
    'node_uri'            => $node_uri,
    'rnode_uri'           => $rnode_uri,
    'nginx_uri'           => $nginx_uri,
    'pun_uri'             => $pun_uri,
    'pun_socket_root'     => $pun_socket_root,
    'pun_max_retries'     => $pun_max_retries,
    'oidc_uri'            => $oidc_uri,
    'oidc_discover_uri'   => $oidc_discover_uri,
    'oidc_discover_root'  => $oidc_discover_root,
    'register_uri'        => $register_uri,
    'register_root'       => $register_root,
  })

  contain openondemand::repo
  contain openondemand::install
  contain openondemand::apache
  contain openondemand::config
  contain openondemand::service

  Class['openondemand::repo']
  ->Class['openondemand::install']
  ->Class['openondemand::apache']
  ->Class['openondemand::config']
  ->Class['openondemand::service']

  create_resources('openondemand::cluster', $_clusters)

  if is_array($usr_apps) {
    ensure_resource('openondemand::app::usr', $usr_apps, $usr_app_defaults)
  } elsif is_hash($usr_apps) {
    create_resources('openondemand::app::usr', $usr_apps, $usr_app_defaults)
  } else {
    fail("${module_name}: usr_apps must be an array or hash.")
  }

  create_resources('openondemand::app::dev', $dev_apps, $dev_app_defaults)
  $dev_app_users.each |$user| {
    openondemand::app::dev { $user:
      * => $dev_app_defaults,
    }
  }

  if ! $_develop_mode {
    $apps = deep_merge($openondemand::params::base_apps, $install_apps)
    create_resources('openondemand::install::app', $apps)
  }

}
