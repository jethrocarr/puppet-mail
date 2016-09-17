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
  ) inherits ::mail::params {

  ensure_packages([$packages_dovecot])

  service { $service_dovecot:
    ensure => running,
    enable => true,
  }

  # TODO: Need to re-work this configuration.

  file { '/etc/dovecot/conf.d/01-puppet.conf':
    ensure  => present,
    source  => 'puppet:///modules/s_mail/dovecot.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }

  # The one default file that does clobber our one needs to go
  file {'/etc/dovecot/conf.d/10-ssl.conf':
    ensure  => absent,
    notify  => Service[ $service_dovecot ],
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
