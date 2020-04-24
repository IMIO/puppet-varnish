# == Define: vclconfig
#
#  Create a vcl config for a site
#
# === Parameters
#
# [*backend*]
#   Name of the backend to connect for this site
#
# [*vcl_config*]
#   Configuration template to use
#
# [*aliases*]
#   host aliases to match before using this config
#
define varnish::vclconfig ($backend, $vcl_config='default', $ensure='present',
  $aliases=[], $order='50') {

    if is_string($aliases) {
      $alias_list = split($aliases, ',')
    }
    else {
      $alias_list = $aliases
    }
    $backend_config = puppetdb_query("resources{type='Varnish::Backend' and title='${backend}'}")[0]
    if $::environment == 'production' {
      $frontend_dns = 'frontend.imio.be'
    } else {
      $frontend_dns = 'frontend-staging.imio.be'
    }
    if $backend_config['parameters']['python3'] {
      $ddir = 'plone5_ddir'
    } else {
      $ddir = 'plone4_ddir'
    }

    file {
        "/etc/varnish/sites/${name}.vcl":
            ensure  => $ensure,
            content => template("varnish/${vcl_config}_vcl_config.erb"),
            notify  => Service[$::varnish::service_name],
            require => [Package[$::varnish::package_name], File['/etc/varnish/sites']],
    }
    if $ensure == 'present' {
      concat::fragment {"${name}_varnish_vcl_config":
        target  => '/etc/varnish/sites.vcl',
        content => "include \"/etc/varnish/sites/${name}.vcl\";\n",
        order   => $order,
        notify  => Service[$::varnish::service_name],
        require => Package[$::varnish::package_name],
      }
    }

}
