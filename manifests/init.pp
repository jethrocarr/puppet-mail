# Provisions a full mailserver.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.
#

class mail () {

  class { '::mail::dnscheck':
  } ->
  class { '::mail::certs':
  } ->
  class { '::mail::dovecot': }

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
