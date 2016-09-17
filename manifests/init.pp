# Provisions a full mailserver.
#
# Please refer to the README.md for general instructions or to the `params.pp`
# file for specifics on the various options.
#

class mail () {

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
