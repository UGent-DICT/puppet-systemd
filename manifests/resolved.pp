# This class provides an abstract way to trigger resolved.
# Each parameters correspond to resolved.conf(5):
# https://www.freedesktop.org/software/systemd/man/resolved.conf.html
#
# @param service_name
#   Name of the logind service to manage
#
# @param config_path
#   Filesystem path to the logind configuration path
#
# @param ensure
#   The state that the ``resolved`` service should be in
#
# @param dns
#   A space-separated list of IPv4 and IPv6 addresses to use as system DNS servers.
#   DNS requests are sent to one of the listed DNS servers in parallel to suitable
#   per-link DNS servers acquired from systemd-networkd.service(8) or set at runtime
#   by external applications. requires puppetlabs-inifile
#
# @param fallback_dns
#   A space-separated list of IPv4 and IPv6 addresses to use as the fallback DNS
#   servers. Any per-link DNS servers obtained from systemd-networkd take
#   precedence over this setting. requires puppetlabs-inifile
#
# @param domains
#   A space-separated list of domains host names or IP addresses to be used
#   systemd-resolved take precedence over this setting.
#
# @param llmnr
#   Takes a boolean argument or "resolve".
#
# @param multicast_dns
#   Takes a boolean argument or "resolve".
#
# @param dnssec
#   Takes a boolean argument or "allow-downgrade".
#
# @param dnsovertls
#   Takes a boolean argument or "opportunistic" or "no"
#
# @param cache
#   Takes a boolean argument or "no-negative".
#
# @param dns_stub_listener
#   Takes a boolean argument or one of "udp" and "tcp".
#
# @param use_stub_resolver
#   Takes a boolean argument. When "false" (default) it uses /run/systemd/resolve/resolv.conf
#   as /etc/resolv.conf. When "true", it uses /run/systemd/resolve/stub-resolv.conf
#
class systemd::resolved (
  String $service_name,
  Stdlib::Unixpath $config_path,
  Enum['stopped','running'] $ensure                                  = 'running',
  Optional[Variant[Array[String],String]] $dns                       = undef,
  Optional[Variant[Array[String],String]] $fallback_dns              = undef,
  Optional[Variant[Array[String],String]] $domains                   = undef,
  Optional[Variant[Boolean,Enum['resolve']]] $llmnr                  = undef,
  Optional[Variant[Boolean,Enum['resolve']]] $multicast_dns          = undef,
  Optional[Variant[Boolean,Enum['allow-downgrade']]] $dnssec         = undef,
  Optional[Variant[Boolean,Enum['opportunistic', 'no']]] $dnsovertls = false,
  Optional[Variant[Boolean,Enum['no-negative']]] $cache              = false,
  Optional[Variant[Boolean,Enum['udp', 'tcp']]] $dns_stub_listener   = undef,
  Boolean $use_stub_resolver                                         = false,
) {

  $_enable_resolved = $ensure ? {
    'stopped' => false,
    'running' => true,
    default   => $ensure,
  }

  service { $service_name:
    ensure => $ensure,
    enable => $_enable_resolved,
  }

  $_resolv_conf_target = $use_stub_resolver ? {
    true    => '/run/systemd/resolve/stub-resolv.conf',
    default => '/run/systemd/resolve/resolv.conf',
  }
  file { '/etc/resolv.conf':
    ensure  => 'symlink',
    target  => $_resolv_conf_target,
    require => Service[$service_name],
  }

  if $dns {
    if $dns =~ String {
      $_dns = $dns
    } else {
      $_dns = join($dns, ' ')
    }
    ini_setting { 'dns':
      ensure  => 'present',
      value   => $_dns,
      setting => 'DNS',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  if $fallback_dns {
    if $fallback_dns =~ String {
      $_fallback_dns = $fallback_dns
    } else {
      $_fallback_dns = join($fallback_dns, ' ')
    }
    ini_setting { 'fallback_dns':
      ensure  => 'present',
      value   => $_fallback_dns,
      setting => 'FallbackDNS',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  if $domains {
    if $domains =~ String {
      $_domains = $domains
    } else {
      $_domains = join($domains, ' ')
    }
    ini_setting { 'domains':
      ensure  => 'present',
      value   => $_domains,
      setting => 'Domains',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  $_llmnr = $llmnr ? {
    true    => 'yes',
    false   => 'no',
    default => $llmnr,
  }

  if $_llmnr {
    ini_setting { 'llmnr':
      ensure  => 'present',
      value   => $_llmnr,
      setting => 'LLMNR',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  $_multicast_dns = $multicast_dns ? {
    true    => 'yes',
    false   => 'no',
    default => $multicast_dns,
  }

  if $_multicast_dns {
    ini_setting { 'multicast_dns':
      ensure  => 'present',
      value   => $_multicast_dns,
      setting => 'MulticastDNS',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  $_dnssec = $dnssec ? {
    true    => 'yes',
    false   => 'no',
    default => $dnssec,
  }

  if $_dnssec {
    ini_setting { 'dnssec':
      ensure  => 'present',
      value   => $_dnssec,
      setting => 'DNSSEC',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  $_dnsovertls = $dnsovertls ? {
    true    => 'opportunistic',
    false   => false,
    default => $dnsovertls,
  }

  if $_dnsovertls {
    ini_setting { 'dnsovertls':
      ensure  => 'present',
      value   => $_dnsovertls,
      setting => 'DNSOverTLS',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  $_cache = $cache ? {
    true    => 'yes',
    false   => 'no',
    default => $cache,
  }

  if $cache {
    ini_setting { 'cache':
      ensure  => 'present',
      value   => $_cache,
      setting => 'Cache',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }

  $_dns_stub_listener = $dns_stub_listener ? {
    true    => 'yes',
    false   => 'no',
    default => $dns_stub_listener,
  }

  if $_dns_stub_listener {
    ini_setting { 'dns_stub_listener':
      ensure  => 'present',
      value   => $_dns_stub_listener,
      setting => 'DNSStubListener',
      section => 'Resolve',
      path    => $config_path,
      notify  => Service[$service_name],
    }
  }
}
