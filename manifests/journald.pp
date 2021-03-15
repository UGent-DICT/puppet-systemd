# This class manages and configures journald.
#
# https://www.freedesktop.org/software/systemd/man/journald.conf.html
#
# @param service_name
#   Name of the journald service
# @param config_path
#   Filesystem path to the journald configuration file
# @param ensure_service
#   State that the journald service should be in
# @param settings
#   Config Hash that is used to configure settings in journald.conf
#
class systemd::journald(
  String $service_name,
  Stdlib::Unixpath $config_path,
  Enum['running','stopped'] $ensure_service = 'running',
  Systemd::JournaldSettings $settings = {},
) {

  service { $service_name:
    ensure => $ensure_service,
  }

  $settings.each |$option, $value| {
    ini_setting {
      $option:
        path    => $config_path,
        section => 'Journal',
        setting => $option,
        notify  => Service[$service_name],
    }
    if $value =~ Hash {
      Ini_setting[$option] {
        * => $value,
      }
    } else {
      Ini_setting[$option] {
        value   => $value,
      }
    }
  }
}
