# This sub-class provisions the Dovecot service. It should not be invoked
# directly, instead it's invoked by the main `mail` module.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.

class mail::dovecot (
  $packages_dovecot  = $::mail::params::packages_dovecot,
  $service_dovecot   = $::mail::params::service_dovecot,
  $security_ssl_key  = $::mail::params::security_ssl_key,
  $security_ssl_cert = $::mail::params::security_ssl_cert,
  $security_ssl_ca   = $::mail::params::security_ssl_ca,
  $security_cert_dir = $::mail::params::security_cert_dir,
  ) inherits ::mail::params {

  ensure_packages([$packages_dovecot])

  service { $service_dovecot:
    ensure => running,
    enable => true,
  }


  # Deploy our configuration into the OS-provided configuration structure.
  # TODO: This will be RHEL-specific.
  file { '/etc/dovecot/conf.d/01-puppet.conf':
    ensure  => present,
    content => template('mail/dovecot.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }


  # On RedHat, we need to remove the default SSL configuration that conflicts
  # with the SSL configuration we've loaded in via our module.
  if ($::osfamily == 'RedHat') {

    file {'/etc/dovecot/conf.d/10-ssl.conf':
      ensure  => 'file',
      content => '# Disabled by Puppet',
      notify  => Service[ $service_dovecot ],
     }
  }


  # Install a default Sieve configuration for all new user accounts.
  file { '/etc/skel/.dovecot.sieve':
    ensure  => present,
    source  => 'puppet:///modules/mail/sieve.default',
    mode    => 0600,
    owner   => 'root',
    group   => 'root',
  }




}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
