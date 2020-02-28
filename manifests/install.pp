# == Class varnish::install
#
class varnish::install {

  if $::varnish::addrepo == true {
    Package[$::varnish::package_name] {
      require => $::varnish::repo::package_require,
    }
  }

  package { $::varnish::package_name:
    ensure  => $::varnish::package_ensure,
  }

  if !empty($::varnish::modules) {
    package {
      $::varnish::modules:
        ensure  => 'present',
        require => [
          $::varnish::repo::package_require,
          Apt::Source['uplex-varnish']
        ],
    }
  }

}
