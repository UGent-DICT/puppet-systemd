# This module allows triggering systemd commands once for all modules
#
# @api public
#
# @param service_limits
#   May be passed a resource hash suitable for passing directly into the
#   ``create_resources()`` function as called on ``systemd::service_limits``
#
# @param manage_resolved
#   Manage the systemd resolver
#
# @param resolved_ensure
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
#   Takes a boolean argument or "opportunistic"
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
# @param manage_networkd
#   Manage the systemd network daemon
#
# @param networkd_ensure
#   The state that the ``networkd`` service should be in
#
# @param manage_timesyncd
#   Manage the systemd tiemsyncd daemon
#
# @param timesyncd_ensure
#   The state that the ``timesyncd`` service should be in
#
# @param ntp_server
#   comma separated list of ntp servers, will be combined with interface specific
#   addresses from systemd-networkd. requires puppetlabs-inifile
#
# @param fallback_ntp_server
#   A space-separated list of NTP server host names or IP addresses to be used
#   as the fallback NTP servers. Any per-interface NTP servers obtained from
#   systemd-networkd take precedence over this setting. requires puppetlabs-inifile
#
# @param manage_journald
#   Manage the systemd journald
#
# @param journald_settings
#   Config Hash that is used to configure settings in journald.conf
#
# @param manage_udevd
#   Manage the systemd udev daemon
#
# @param udev_log
#   The value of /etc/udev/udev.conf udev_log
#
# @param udev_children_max
#   The value of /etc/udev/udev.conf children_max
#
# @param udev_exec_delay
#   The value of /etc/udev/udev.conf exec_delay
#
# @param udev_event_timeout
#   The value of /etc/udev/udev.conf event_timeout
#
# @param udev_resolve_names
#   The value of /etc/udev/udev.conf resolve_names
#
# @param udev_timeout_signal
#   The value of /etc/udev/udev.conf timeout_signal
#
# @param udev_rules
#   Config Hash that is used to generate instances of our
#   `udev::rule` define.
#
# @param manage_logind
#   Manage the systemd logind
#
# @param logind_settings
#   Config Hash that is used to configure settings in logind.conf
#
# @param loginctl_users
#   Config Hash that is used to generate instances of our type
#   `loginctl_user`.
#
# @param dropin_files
#   Configure dropin files via hiera with factory pattern
class systemd (
  Hash[String,Hash[String, Any]]                         $service_limits,
  Boolean                                                $manage_resolved,
  Enum['stopped','running']                              $resolved_ensure,
  Optional[Variant[Array[String],String]]                $dns,
  Optional[Variant[Array[String],String]]                $fallback_dns,
  Optional[Variant[Array[String],String]]                $domains,
  Optional[Variant[Boolean,Enum['resolve']]]             $llmnr,
  Optional[Variant[Boolean,Enum['resolve']]]             $multicast_dns,
  Optional[Variant[Boolean,Enum['allow-downgrade']]]     $dnssec,
  Optional[Variant[Boolean,Enum['opportunistic', 'no']]] $dnsovertls,
  Optional[Variant[Boolean,Enum['no-negative']]]         $cache,
  Optional[Variant[Boolean,Enum['udp','tcp']]]           $dns_stub_listener,
  Boolean                                                $use_stub_resolver,
  Boolean                                                $manage_networkd,
  Enum['stopped','running']                              $networkd_ensure,
  Boolean                                                $manage_timesyncd,
  Enum['stopped','running']                              $timesyncd_ensure,
  Optional[Variant[Array,String]]                        $ntp_server,
  Optional[Variant[Array,String]]                        $fallback_ntp_server,
  Boolean                                                $manage_accounting,
  Hash[String,String]                                    $accounting,
  Boolean                                                $purge_dropin_dirs,
  Boolean                                                $manage_journald,
  Systemd::JournaldSettings                              $journald_settings,
  Boolean                                                $manage_udevd,
  Optional[Variant[Integer,String]]                      $udev_log,
  Optional[Integer]                                      $udev_children_max,
  Optional[Integer]                                      $udev_exec_delay,
  Optional[Integer]                                      $udev_event_timeout,
  Optional[Enum['early', 'late', 'never']]               $udev_resolve_names,
  Optional[Variant[Integer,String]]                      $udev_timeout_signal,
  Boolean                                                $manage_logind,
  Systemd::LogindSettings                                $logind_settings,
  Hash                                                   $loginctl_users = {},
  Hash                                                   $dropin_files = {},
  Hash                                                   $udev_rules = {},
) {
  create_resources('systemd::service_limits', $service_limits)

  if $manage_resolved and $facts['systemd_internal_services'] and $facts['systemd_internal_services']['systemd-resolved.service'] {
    class { 'systemd::resolved':
      ensure            => $resolved_ensure,
      dns               => $dns,
      fallback_dns      => $fallback_dns,
      domains           => $domains,
      llmnr             => $llmnr,
      multicast_dns     => $multicast_dns,
      dnssec            => $dnssec,
      dnsovertls        => $dnsovertls,
      cache             => $cache,
      dns_stub_listener => $dns_stub_listener,
      use_stub_resolver => $use_stub_resolver,
    }
  }

  if $manage_networkd and $facts['systemd_internal_services'] and $facts['systemd_internal_services']['systemd-networkd.service'] {
    class { 'systemd::networkd':
      ensure => $networkd_ensure,
    }
  }

  if $manage_timesyncd and $facts['systemd_internal_services'] and $facts['systemd_internal_services']['systemd-timesyncd.service'] {
    class { 'systemd::timesyncd':
      ensure              => $timesyncd_ensure,
      ntp_server          => $ntp_server,
      fallback_ntp_server => $fallback_ntp_server,
    }
  }

  if $manage_udevd {
    class { 'systemd::udevd':
      rules               => $udev_rules,
      udev_log            => $udev_log,
      udev_children_max   => $udev_children_max,
      udev_exec_delay     => $udev_exec_delay,
      udev_event_timeout  => $udev_event_timeout,
      udev_resolve_names  => $udev_resolve_names,
      udev_timeout_signal => $udev_timeout_signal,
    }
  }

  if $manage_accounting {
    class { 'systemd::system':
      accounting => $accounting,
    }
  }

  if $manage_journald {
    class { 'systemd::journald':
      settings => $journald_settings,
    }
  }

  if $manage_logind {
    class { 'systemd::logind':
      settings       => $logind_settings,
      loginctl_users => $loginctl_users,
    }
  }

  $dropin_files.each |$name, $resource| {
    systemd::dropin_file { $name:
      * => $resource,
    }
  }
}
