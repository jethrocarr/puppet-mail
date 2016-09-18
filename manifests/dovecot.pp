# This sub-class provisions the Dovecot service. It should not be invoked
# directly, instead it's invoked by the main `mail` module.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.

class mail::dovecot (
  $packages_dovecot  = $::mail::packages_dovecot,
  $service_dovecot   = $::mail::service_dovecot,
  $server_hostname   = $::mail::server_hostname,
  $security_cert_dir = $::mail::security_cert_dir,
  ) {

  ensure_packages([$packages_dovecot])

  service { $service_dovecot:
    ensure  => running,
    enable  => true,
    require => Package[ $packages_dovecot ],
  }


  # We take the RedHat-style approach and deploy our configuration into the
  # provided /etc/dovecot/conf.d/ directory. Whilst we could create a cutdown
  # "one file" style configuration file and purge all the files we don't want,
  # this would put us at risk of the config breaking next time Dovecot gets
  # updated by the OS. By maintaining the same structural convention, the
  # config get respected by the package manager.

  file {'/etc/dovecot/dovecot.conf':
    ensure  => 'file',
    content => template('mail/dovecot.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/10-auth.conf':
    ensure  => 'file',
    content => template('mail/dovecot/10-auth.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/10-director.conf':
    ensure  => 'file',
    content => template('mail/dovecot/10-director.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/10-logging.conf':
    ensure  => 'file',
    content => template('mail/dovecot/10-logging.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/10-mail.conf':
    ensure  => 'file',
    content => template('mail/dovecot/10-mail.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/10-master.conf':
    ensure  => 'file',
    content => template('mail/dovecot/10-master.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/10-ssl.conf':
    ensure  => 'file',
    content => template('mail/dovecot/10-ssl.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/15-lda.conf':
    ensure  => 'file',
    content => template('mail/dovecot/15-lda.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/15-mailboxes.conf':
    ensure  => 'file',
    content => template('mail/dovecot/15-mailboxes.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/20-imap.conf':
    ensure  => 'file',
    content => template('mail/dovecot/20-imap.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/20-managesieve.conf':
    ensure  => 'file',
    content => template('mail/dovecot/20-managesieve.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/20-pop3.conf':
    ensure  => 'file',
    content => template('mail/dovecot/20-pop3.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/90-acl.conf':
    ensure  => 'file',
    content => template('mail/dovecot/90-acl.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/90-plugin.conf':
    ensure  => 'file',
    content => template('mail/dovecot/90-plugin.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/90-quota.conf':
    ensure  => 'file',
    content => template('mail/dovecot/90-quota.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/90-sieve-extprograms.conf':
    ensure  => 'file',
    content => template('mail/dovecot/90-sieve-extprograms.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }
  file {'/etc/dovecot/conf.d/90-sieve.conf':
    ensure  => 'file',
    content => template('mail/dovecot/90-sieve.conf.erb'),
    require => Package[ $packages_dovecot ],
    notify  => Service[ $service_dovecot ],
  }


  # Install a default Sieve configuration for all new user accounts.
  file { '/etc/skel/.dovecot.sieve':
    ensure  => present,
    source  => 'puppet:///modules/mail/sieve.default',
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
  }




}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
