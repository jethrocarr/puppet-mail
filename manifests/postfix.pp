# This sub-class provisions the Postfix service. It should not be invoked
# directly, instead it's invoked by the main `mail` module.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.

class mail::postfix (
  $packages_postfix          = $::mail::packages_postfix,
  $server_hostname           = $::mail::server_hostname,
  $server_domain             = $::mail::server_domain,
  $server_label              = $::mail::server_label,
  $virtual_domains           = $::mail::virtual_domains,
  $virtual_addresses         = $::mail::virtual_addresses,
  $security_trusted_networks = $::mail::security_trusted_networks,
  $security_cert_dir         = $::mail::security_cert_dir,
  $enable_graylisting        = $::mail::enable_graylisting,
  $enable_antispam           = $::mail::enable_antispam,
  $antispam_sa_score         = $::mail::antispam_sa_score,
  $max_message_size_mb       = $::mail::max_message_size_mb,
  ) {

  # Install additional dependencies
  ensure_packages([$packages_postfix])

  # If the user hasn't supplied any virtual domains, assume they intended to
  # supply the domain of this server itself.
  if (empty($virtual_domains_tweaked)) {
    $virtual_domains_tweaked = [ $server_domain ]
  } else {
    $virtual_domains_tweaked = $virtual_domains
  }

  # Here we configure Postfix. It's a pretty complex beast, most of the actual
  # logic is currently provided by a third party module which has been forked
  # and adjusted slightly. Longer term I may merge the module into this one
  # after simplifying.
  class { '::postfix::server':
    myhostname         => $server_hostname,
    mydomain           => $server_domain,
    mydestination      => "\$myhostname, localhost.\$mydomain, localhost",
    mynetworks         => $security_trusted_networks,
    inet_interfaces    => 'all',
    message_size_limit => "${max_message_size_mb}000000", # mb in bytes
    spampd_maxsize     => "${max_message_size_mb}000",    # mb in kilobytes
    mailbox_size_limit => '0', # unlimited
    mail_name          => $server_label,

    # Virtual domains & mappings
    virtual_alias_maps      => ['hash:/etc/postfix/virtual'],
    virtual_mailbox_domains => $virtual_domains_tweaked,

    # Dovecot Integration
    # Note: need both mailbox_command and virtual_transport to cater for both virtual and real users alike.
    # TODO: This is probably RHEL specific.
    mailbox_command    => '/usr/libexec/dovecot/dovecot-lda -f "$SENDER" -a "$RECIPIENT"', 
    virtual_transport  => 'dovecot',

    # Rules around recieving email (this is not for clients as in our
    # authenticated users, but rather any server sending us requests).
    # http://www.postfix.org/postconf.5.html#smtpd_client_restrictions
    smtpd_client_restrictions => [
      'permit_mynetworks',
      'permit_sasl_authenticated',
      'reject_unknown_client_hostname', # Ensure RDNS matches the server name
      'reject_unauth_pipelining',       # Reject any out-of-order SMTP commands
    ],

    # Rules run against the HELO header
    # http://www.postfix.org/postconf.5.html#smtpd_helo_restrictions
    smtpd_helo_required     => true,
    smtpd_helo_restrictions => [
      'permit_mynetworks',
      'permit_sasl_authenticated',
      'reject_invalid_helo_hostname',
      'reject_non_fqdn_helo_hostname',
      'reject_unknown_helo_hostname',
    ],

    # Rules run against the RCPT TO header
    # http://www.postfix.org/postconf.5.html#smtpd_recipient_restrictions
    smtpd_recipient_restrictions => [
      'permit_mynetworks',
      'permit_sasl_authenticated',
      'reject_unauth_destination',
    ],

    # Rules run against the MAIL FROM header
    # http://www.postfix.org/postconf.5.html#smtpd_sender_restrictions
    smtpd_sender_restrictions => [
      'permit_mynetworks',
      'reject_unknown_sender_domain',
      'reject_non_fqdn_sender',
    ],

    # submissions & SASL acceptance
    ssl                                 => $server_hostname,
    smtpd_sasl_auth                     => true,
    submission                          => true,
    submission_smtpd_tls_security_level => 'encrypt',

    # Disable authentication on port 25. We only allow auth on submission port
    # 587 since this allows for easy firewall lockdown of authenticable ports.
    smtp_smtpd_sasl_auth_enable => 'no',

    # TLS/SSL encryption using the LetsEncrypt certs
    smtpd_tls_key_file  => "${security_cert_dir}/${server_hostname}/privkey.pem",
    smtpd_tls_cert_file => "${security_cert_dir}/${server_hostname}/cert.pem",
    smtpd_tls_CAfile    => "${security_cert_dir}/${server_hostname}/chain.pem",

    # Spam Prevention
    postgrey            => $enable_graylisting,
    spamassassin        => $enable_antispam,
    sa_required_hits    => '3',
    sa_skip_rbl_checks  => '0',
    spampd_children     => '4',
    smtp_content_filter => ['smtp:127.0.0.1:10026'], # send all mail through spamd
    master_services     => [ '127.0.0.1:10027 inet n  -       n       -      20       smtpd'], # recieve email back from spamd

    # Tweaked Spam Assassin matches/scoring
    sa_loadplugin       => [ 'Mail::SpamAssassin::Plugin::SPF',
                             'Mail::SpamAssassin::Plugin::DCC'
                           ],
    sa_score            => $antispam_sa_score,

  }

  # Setup the virtual alias addresses
  # TODO: Maybe RHEL specific?
  file { '/etc/postfix/virtual':
    ensure  => present,
    content => template('mail/postfix_virtual_aliases_map.erb'),
    notify  => Exec['postmap virtual alias maps'],
    require => Class['::postfix::server'],
  }

  exec { 'postmap virtual alias maps':
    refreshonly => true,
    command     => 'postmap /etc/postfix/virtual',
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
  }
 
}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
