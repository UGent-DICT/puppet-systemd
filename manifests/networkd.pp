# This class provides an abstract way to trigger systemd-networkd
#
# @param service_name
#   Name of the networkd service to manage
# @param ensure
#   The state that the ``networkd`` service should be in
#
class systemd::networkd (
  String $service_name,
  Enum['stopped','running'] $ensure = $systemd::networkd_ensure,
) {

  $_enable_networkd = $ensure ? {
    'stopped' => false,
    'running' => true,
    default   => $ensure,
  }

  service { $service_name:
    ensure => $ensure,
    enable => $_enable_networkd,
  }
}
