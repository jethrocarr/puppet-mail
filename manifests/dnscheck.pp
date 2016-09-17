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

    # This is a hack, basically we want to fail this module in the Puppet run,
    # but not block anything else on the server. If we used the fail() function,
    # it would disrupt the entire Puppet run, which might even involve creating
    # config the box needs to properly set it's hostname. So what we do instead,
    # is define an Exec that will always fail, thus failing this sub class, which
    # will block all the other sub-classes as it's a core dependency in the mail
    # module.

    exec { 'fail':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      command => 'false'
    }

    notify { 'The forward DNS records for this system are incorrect which will block the mail server build steps until resolved': }
  }

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
