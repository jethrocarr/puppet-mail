# This sub-class provisions the SSL/TLS certs used by the mail server. It
# should not be invoked directly, instead it's invoked by the main `mail`
# module.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.

class mail::certs (
  $security_certbot_plugin   = $::mail::security_certbot_plugin,
  $security_certbot_email    = $::mail::security_certbot_email,
  $security_certbot_webroot  = $::mail::security_certbot_webroot,
  $security_certbot_before   = $::mail::security_certbot_before,
  $security_certbot_after    = $::mail::security_certbot_after,
  $server_hostname           = $::mail::server_hostname,
  $service_dovecot           = $::mail::service_dovecot,
  $service_postfix           = $::mail::service_postfix,
  ) {


  # Build the security_certbot_after
  if ($security_certbot_after) {
    $security_certbot_after_real = $security_certbot_after
  } else {
    $security_certbot_after_real = "/sbin/service ${service_dovecot} restart > /dev/null 2>&1; /sbin/service ${service_postfix} restart > /dev/null 2>&1"
  }

  # Perform a safe vs unsafe registration depending on whether a valid email
  # address has been supplied. An unsafe registration means no email notices
  # around expiration or renewal of certs as well as ability to recover from
  # key loss.

  if ($security_certbot_email) {
    class { ::letsencrypt:
      email => $security_certbot_email,
    }
  } else {
    class { ::letsencrypt:
      unsafe_registration => true,
    }
  }


  # Request a cert for the server. Note that this will require functional DNS
  # to be in place so that LetsEncrypt can establish a connection to validate.

  letsencrypt::certonly { 'mail':
    # Provide option to change the type of plugin being used.
    plugin        => $security_certbot_plugin,
    webroot_paths => $security_certbot_webroot,

    # We don't need every domain we are hosting mail for defined in the cert,
    # just the FQDN of the server that is doing the mail serving.
    domains                => [$server_hostname],

    # Make sure we automatically renew certs before expiration via cronjob.
    manage_cron            => true,
    
    # We have to restart any services using the certs when this occurs.
    cron_success_command   => $security_certbot_after_real,
    cron_before_command    => $security_certbot_before,
  }


}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
