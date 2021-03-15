# This class manages systemd's login manager configuration.
#
# https://www.freedesktop.org/software/systemd/man/logind.conf.html
#
# @param service_name
#   Name of the logind service
# @param config_path
#   Filesystem path to the logind configuration file
# @param service_ensure
#   State that the logind service should be in
# @param settings
#   Config Hash that is used to configure settings in logind.conf
# @param loginctl_users
#   Config Hash that is used to generate instances of our type
#   `loginctl_user`.
#
class systemd::logind(
  String $service_name,
  Stdlib::Unixpath $config_path,
  Enum['running','stopped'] $service_ensure = 'running',
  Systemd::LogindSettings $settings = {},
  Hash $loginctl_users = {},
) {

  service { $service_name:
    ensure => $service_ensure,
  }

  $settings.each |$option, $value| {
    ini_setting {
      $option:
        path    => $config_path,
        section => 'Login',
        setting => $option,
        notify  => Service[$service_name],
    }
    if $value =~ Hash {
      Ini_setting[$option] {
        * => $value,
      }
    } elsif $value =~ Array {
      Ini_setting[$option] {
        value   => join($value, ' '),
      }
    } else {
      Ini_setting[$option] {
        value   => $value,
      }
    }
  }

  $loginctl_users.each |$loginctl_name, $loginctl_settings| {
    loginctl_user { $loginctl_name:
      * => $loginctl_settings,
    }
  }
}
