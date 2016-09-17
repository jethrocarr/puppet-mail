# This sub-class validates the DNS configuration for this server. It should not
# be invoked directly, instead it's invoked by the main `mail` module.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.

class mail::dnscheck (
  $server_hostname = $::mail::server_hostname,
  ) {


  # Validate that the forward DNS for this server is properly configured as we
  # require it to generate the LetsEncrypt certs (and probably to recieve mail
  # as well) ;-)
  
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

    warning('The forward DNS records for this system are incorrect which will block the mail server build steps until resolved')
  }

  # Validate that the server has correctly configured reverse DNS. Without
  # valid RDNS, major providers (Google, Yahoo, etc) will not accept email from
  # this server.
  #
  # TODO: Add reverse DNS check here using custom Puppet function.

  # Validate that each virtual domain has valid SPF data. Since we
  # TODO: Add SPF check for each of the domains.

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
