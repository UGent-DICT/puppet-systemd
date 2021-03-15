# This class manages systemd's udev config
#
# https://www.freedesktop.org/software/systemd/man/udev.conf.html
#
# @param service_name
#   Name of the udevd service to manage
# @param config_path
#   Filesystem path to the udevd configuration file
# @param service_ensure
#   State that the udevd service should be in
# @param enable_service
#   Whether the udevd service should be started on system boot
# @param udev_log
#   The value of /etc/udev/udev.conf udev_log
# @param udev_children_max
#   The value of /etc/udev/udev.conf children_max
# @param udev_exec_delay
#   The value of /etc/udev/udev.conf exec_delay
# @param udev_event_timeout
#   The value of /etc/udev/udev.conf event_timeout
# @param udev_resolve_names
#   The value of /etc/udev/udev.conf resolve_names
# @param udev_timeout_signal
#   The value of /etc/udev/udev.conf timeout_signal
# @param rules
#   Config Hash that is used to generate instances of our
#   `udev::rule` define.
#
class systemd::udevd(
  String $service_name,
  Stdlib::Unixpath $config_path,
  Enum['running', 'stopped'] $service_ensure = 'running',
  Boolean $enable_service = true,
  Optional[Variant[Integer,String]] $udev_log = undef,
  Optional[Integer] $udev_children_max = undef,
  Optional[Integer] $udev_exec_delay = undef,
  Optional[Integer] $udev_event_timeout = undef,
  Optional[Enum['early', 'late', 'never']] $udev_resolve_names = undef,
  Optional[Variant[Integer,String]] $udev_timeout_signal = undef,
  Hash $rules = {},
) {

  service { $service_name:
    ensure => $service_ensure,
    enable => $enable_service,
  }

  file { $config_path:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => epp("${module_name}/udev_conf.epp", {
        'udev_log'            => $udev_log,
        'udev_children_max'   => $udev_children_max,
        'udev_exec_delay'     => $udev_exec_delay,
        'udev_event_timeout'  => $udev_event_timeout,
        'udev_resolve_names'  => $udev_resolve_names,
        'udev_timeout_signal' => $udev_timeout_signal,
    }),
    notify  => Service[$service_name],
  }

  $rules.each |$udev_rule_name, $udev_rule| {
    systemd::udev::rule { $udev_rule_name:
      * => $udev_rule,
    }
  }
}
