# This class provides a solution to enable accounting
#
# @param config_path
#   Filesystem path to the system configuration ile
# @param accounting
#   Systemd accounting rules to set up
#
class systemd::system(
  Stlib::Unixpath $config_path,
  Hash[String, String] $accounting = {},
) {
  $accounting.each |$option, $value| {
    ini_setting { $option:
      ensure  => 'present',
      section => 'Manager',
      path    => $config_path,
      setting => $option,
      value   => $value,
    }
  }
}
