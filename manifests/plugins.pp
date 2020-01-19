class elkstack::plugins (
  $plugins      = $::elkstack::plugins,
  $root_dir     = $::elkstack::root_dir,
  $with_prefix  = $::elkstack::with_prefix,
){
  $plugins.each |$app, $plugin| {
    if ($with_prefix) {
      $prefix="${app}-"
    }

    if ($app == 'elasticsearch') {
      $plugin.each |$p| {
        exec { "install ${p}":
          cwd     => '/usr/share/elasticsearch',
          command => "/usr/share/elasticsearch/bin/${prefix}plugin install ${p}",
          creates => "/usr/share/elasticsearch/plugins/${p}",
          notify  => Service[$app],
        }
      }
    } elsif ($app == 'logstash') {
      $plugin.each |$p| {
        exec { "install ${p}":
          cwd     => "${root_dir}/logstash",
          command => "${root_dir}/logstash/bin/${prefix}plugin install ${p}",
          unless  => "/usr/bin/find /opt/logstash/vendor/bundle/jruby/1.9/gems/ -type d | grep ${p}",
        }
      }
    } elsif ($app == 'kibana') {
      $plugin.each |$p| {
        $p_real = regsubst($p, '^(?:[^/]+)/([^/]+)(?:/?.*)$', '\1')
        exec { "install ${p} into kibana":
          command => "${root_dir}/kibana/bin/${prefix}kibana plugin --install ${p}",
          creates => "${root_dir}/kibana/installedPlugins/${p_real}",
          notify  => Service['kibana'],
        }
      }
    } elsif ($app == 'drivers') {
      $plugin.each |$p| {
        $driver = regsubst($p, '^(?:.+)/([^/]+)$', '\1')
        exec { "download ${driver}":
          cwd     => '/usr/share/elasticsearch/lib',
          command => "/usr/bin/wget ${p}",
          creates => "/usr/share/elasticsearch/lib/${driver}",
          notify  => [Service['elasticsearch'],Service['kibana']],
        }

      }
    }
  }
}

