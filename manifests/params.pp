# Default configuration for this module. Any changes to these values should
# be made in Hiera, rather than directly to the module.

class mail::params {

  # Packages providing the apps & the required dependencies we have. You should
  # not need to adjust this unless adding support for a new distribution. PRs
  # always welcome for more distribution/platform support.
  $packages_dovecot = $::osfamily ? {
    'RedHat' => ['dovecot', 'dovecot-pigeonhole'],
    'Debian' => ['dovecot-core', 'dovecot-imapd', 'dovecot-sieve', 'dovecot-lmtpd'],
    default  => ['dovecot', 'dovecot-pigeonhole']
  }

  $packages_postfix = $::osfamily ? {
    'RedHat' => ['perl-Mail-SPF'],
    'Debian' => ['libmail-spf-perl'],
    default  => ['perl-Mail-SPF']
  }

  # Service names. Just like with packages above, these can vary by operating
  # system but shouldn't generally need changing by end users of this module.
  $service_dovecot = $::osfamily ? {
    'RedHat' => 'dovecot',
    default  => 'dovecot',
  }

  $service_postfix = $::osfamily ? {
    'RedHat' => 'postfix',
    default  => 'postfix',
  }

  # Paths that vary by platform
  $path_dovecot_lda = $::osfamily ? {
    'RedHat' => '/usr/libexec/dovecot/dovecot-lda',
    'Debian' => '/usr/lib/dovecot/dovecot-lda',
    default  => '/usr/lib/dovecot/dovecot-lda',
  }


  # Define the mail server name and attributes
  $server_hostname = $::fqdn
  $server_domain   = $::domain
  $server_label    = "A ${::operatingsystem} powered mail server"

  # Define an array of domains to send/receive mail for. You'll want to define
  # at least one (the domain the server is on!).
  $virtual_domains = []

  # Define a hash of virtual email aliases. The key must be the fully qualified
  # email address, and the value must be a local shell user.
  #
  # For example:
  # $virtual_addresses = {
  #   "user@example.com"     => "user",
  #   "nickname@example.com" => "user",
  # }
  #
  $virtual_addresses = {}


  # Enable spam filtering using SpamAssassin. If disabled, none of the other
  # subsequent antispam_* settings have any effect.
  $enable_antispam = true

  # SpamAssassin scoring is highly configurable and you will have your own
  # specific views on what the "best" configuration is. The version in
  # params.pp is intended to be a good default that you can iterate on.
  $antispam_sa_score = [ 'FH_DATE_PAST_20XX 0',
                         'FREEMAIL_FORGED_REPLYTO 2.0',
                         'FREEMAIL_FROM 2.0',
                         'FREEMAIL_REPLY 1.0',
                         'HTML_EMBEDS 2.0',
                         'HTML_MESSAGE 0.5',
                         'HTML_IMAGE_ONLY_24 1.9',
                         'LOTS_OF_MONEY 0.2',
                         'MIME_HTML_ONLY 1.7',
                         'MPART_ALT_DIFF_COUNT 2.0',
                         'T_REMOTE_IMAGE 0.5',
                         'URI_HEX 1.2']


  # Graylisting is a controversial approach to helping reduce spam. It works by
  # the mail server declining the first attempt to deliver any piece of a mail
  # from a new domain. This in turn upsets a lot of spam bots which are not
  # programmed properly to retry, whilst legit providers will always retry a
  # few mins later.
  #
  # If you find that emails arrive with a delay and it frustrates you, you may
  # wish to disable this. It is also often desirable to disable when doing
  # initial setup and testing of the server.
  $enable_graylisting = true


  # Define the maximum message size you will accept. If the message is larger
  # than this, it will be refused and the sender will recieve a bounce message
  # explaining that their attachments are too big. Defaults to 50MB.
  $max_message_size_mb = '50' 



  # Define trusted network ranges. Any networks in this array are permitted to
  # relay any amount of email through this server without authentication, so
  # they really must be trusted networks!
  $security_trusted_networks = []

  # We use LetsEncrypt (CertBot) for generating valid SSL/TLS certs for the
  # mail server. By default we don't associate an email address with those
  # certs, but in a production environment you may wish to consider doing so
  # in order to get expiration and renewal information.
  $security_certbot_email  = undef

  # Our mode for validating our server's identity involves starting and stopping
  # a temporary server for validating with LetEncrypt. This will break if you
  # are already running a webserver on the same machine. If so, recommend
  # setting:
  # 
  #   security_certbot_plugin: 'webroot'
  #   security_certbot_webroot: '/var/www/html/'
  #
  $security_certbot_plugin  = 'standalone'
  $security_certbot_webroot = undef

  # Define where the cert files are being stored.
  $security_cert_dir    = '/etc/letsencrypt/live/'

}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
