# == Class elkstack::config
#
# This class is called from elkstack for service config.
#
class elkstack::config (
  $es_config     = $::elkstack::es_config,
  $kibana_config = $::elkstack::kibana_config,
  $logstash_config_output = $::elkstack::logstash_config_output,
  $logstash_config_input = $::elkstack::logstash_config_input,
){
  file {'kibana nginx config':
    ensure  => file,
    content => file('elkstack/kibana.nginx.conf'),
    path    => '/etc/nginx/conf.d/kibana.conf',
    notify  => Service['nginx'],
  }
  file_line { 'elasticsearch url for kibana':
    ensure => present,
    line   => 'elasticsearch.url: "http://localhost:9200"',
    path   => '/opt/kibana/config/kibana.yml',
    notify => Service['kibana'],
  }

  $kibana_config.each |String $line| {
    file_line { $line:
      ensure => present,
      line   => $line,
      path   => '/opt/kibana/config/kibana.yml',
      notify => Service['kibana'],
    }
  }
  $es_config.each |String $line| {
    file_line { $line:
      ensure => present,
      line   => $line,
      path   => '/etc/elasticsearch/elasticsearch.yml',
      notify => Service['elasticsearch'],
    }
  }
  $logstash_config_input.each |$conf_file, $contents| {
    file { "/etc/logstash/conf.d/${conf_file}-input.conf":
      ensure  => present,
      content => template('elkstack/logstash.input.conf.erb'),
    }
  }
  $logstash_config_output.each |$conf_file, $contents| {
    file { "/etc/logstash/conf.d/${conf_file}-output.conf":
      ensure  => present,
      content => template('elkstack/logstash.output.conf.erb'),
    }
  }

  #    $contents.each |String $config| {
  #      file_line { $config:
  #        ensure => present,
  #        line   => $config,
  #        path   => "/etc/logstash/conf.d/${conf_file}",
  #      }
  #    }
  #
  #  }
}
