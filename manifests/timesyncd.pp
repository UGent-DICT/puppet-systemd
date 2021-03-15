# This class provides an abstract way to trigger systemd-timesyncd
#
# @param service_name
#   Name of the timesyncd service to manage
#
# @param config_path
#   Filesystem path to the timesyncd configuration file
#
# @param ntp_server
#   A space-separated list of NTP servers, will be combined with interface specific
#   addresses from systemd-networkd. requires puppetlabs-inifile
#
# @param fallback_ntp_server
#   A space-separated list of NTP server host names or IP addresses to be used
#   as the fallback NTP servers. Any per-interface NTP servers obtained from
#   systemd-networkd take precedence over this setting. requires puppetlabs-inifile
#
# @param ensure
#   The state that the ``networkd`` service should be in
#
# @param package_name
#   Name of the systemd-timesyncd system package, if applicable.
#
# @param package_ensure
#   State of the systemd-timesyncd package
#
class systemd::timesyncd (
  String $service_name,
  Stdlib::Unixpath $config_path,
  Variant[Array,String] $ntp_server,
  Variant[Array,String] $fallback_ntp_server,
  Enum['stopped','running'] $ensure = 'running',
  Optional[String] $package_name = undef,
  String $package_ensure = 'installed',
) {

  $_enable_service = $ensure ? {
    'stopped' => false,
    'running' => true,
    default   => $ensure,
  }

  $_service_defaults = {
    'ensure' => $ensure,
    'enable' => $_enable_service,
  }

  if $package_name {
    package { $package_name:
      ensure => $package_ensure,
    }

    $_service_require = {
      'require' => "Package[${package_name}]",
    }
  } else {
    $_service_require = {}
  }

  service { $service_name:
    * => $_service_defaults + $_service_require,
  }

  if $ntp_server {
    if $ntp_server =~ String {
      $_ntp_server = $ntp_server
    } else {
      $_ntp_server = join($ntp_server, ' ')
    }
    ini_setting { 'ntp_server':
      ensure  => 'present',
      value   => $_ntp_server,
      setting => 'NTP',
      section => 'Time',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  if $fallback_ntp_server {
    if $fallback_ntp_server =~ String {
      $_fallback_ntp_server = $fallback_ntp_server
    } else {
      $_fallback_ntp_server = join($fallback_ntp_server, ' ')
    }
    ini_setting { 'fallback_ntp_server':
      ensure  => 'present',
      value   => $_fallback_ntp_server,
      setting => 'FallbackNTP',
      section => 'Time',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }
}
