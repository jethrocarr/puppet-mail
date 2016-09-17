# This sub-class validates the DNS configuration for this server. It should not
# be invoked directly, instead it's invoked by the main `mail` module.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.

class mail::dnscheck (
  $server_hostname           = $::mail::params::server_hostname,
  ) inherits ::mail::params {

  # Validate that the DNS for this server is properly configured. It is very
  # important to make sure both forward and reverse DNS is functional in order
  # to generate certs, but also because RDNS is critical for mail acceptance.

  if (!mailcheckdnsforwards($server_hostname)) {
    fail('The forward DNS for this system is incorrect which will block the Puppet run')
  }

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
