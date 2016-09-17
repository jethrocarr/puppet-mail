# Provisions a full mailserver.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.
#

class mail (
  $packages_dovecot          = $::mail::params::packages_dovecot,
  $packages_postfix          = $::mail::params::packages_postfix,
  $security_certbot_plugin   = $::mail::params::security_certbot_plugin,
  $security_certbot_email    = $::mail::params::security_certbot_email,
  $security_cert_dir         = $::mail::params::security_cert_dir,
  $security_trusted_networks = $::mail::params::security_trusted_networks,
  $server_hostname           = $::mail::params::server_hostname,
  $service_dovecot           = $::mail::params::service_dovecot,
  $virtual_domains           = $::mail::params::virtual_domains,
  $virtual_addresses         = $::mail::params::virtual_addresses,
  $enable_graylisting        = $::mail::params::enable_graylisting,
  $enable_antispam           = $::mail::params::antispam_sa_score,
  $max_message_size_mb       = $::mail::params::max_message_size_mb,
) inherits ::mail::params {

  # Because of packages missing on CentOS, we need the EPEL repo (for
  # LetsEncrypt in particular) and we also need repos.jethrocarr.com to get
  # the spampd module for assisting with SpamAssassin configuration.
  if ($::operatingsystem == 'CentOS') {
    require epel
    require repo_jethro
  }

  # We specifically define the order of the modules as each one requires
  # various resources from the previous.
  class { '::mail::dnscheck':
  } ->
  class { '::mail::certs':
  } ->
  class { '::mail::dovecot':
  } ->
  class { '::mail::postfix': }


}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
