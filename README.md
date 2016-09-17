# puppet-mail

# Overview

Running your own mail server can be a powerful and rewarding experience, but it
does tend to come with a number of challanges. Mail servers tend to have
extremely complex configurations and it's easy to make a mistake that weakens
security or allows spam through.

This Puppet module has been designed for hobbyists or small organisation mail
server operators whom want an easy solution to build and manage a mail server
that doesn't try to be too complex. If you're running an ISP with 30,000
mailboxes, this probably isn't the module for you. But 5 users? Yourself only?
Keep on reading!


# Features

* Uses Postfix as the MTA
* Uses Dovecot for providing IMAP
* Enforces SSL/TLS and generates a legitimate cert automatically with
  LetsEncrypt.
* Filters spam using SpamAssassin
* Provides Sieve for server-side email filtering rules.
* Simple authentication against PAM for easy management of users.
* Supports virtual email aliases and multiple domains


# Requirements

Currently only the following distributions are supported - PRs adding support
for other distributions are always welcome.

* CentOS (7)

You must include the following Puppet module dependencies - ideally in your
`Puppetfile` if using an r10k workflow.

    mod 'puppetlabs/stdlib'
    
    # EPEL & Jethro Repo modules only required for CentOS/RHEL systems
    mod 'stahnma/epel'
    mod 'jethrocarr/repo_jethro'
    
    # Note that the letsencrypt module needs to be the upstream Github version,
    # the version on PuppetForge is too old.
    mod 'letsencrypt',
      :git    => 'https://github.com/danzilio/puppet-letsencrypt.git',
      :branch => 'master'
    
    # This postfix module is a fork of thias/puppet-postfix with some fixes
    # to make it more suitable for the needs of this module. Longer-term,
    # expect to merge it into this one and drop unnecessary functionality.
    mod 'postfix',
      :git    => 'https://github.com/jethrocarr/puppet-postfix.git',
      :branch => 'master'



# Usage

To provision the mailserver, simply add the following to your own modules or
`site.pp` file:

    class { 'mail': }

Naturally you'll want to do some configuration of the mailserver. This is best
done in Puppet Hiera. The following is an example of the minimum options you'd
want to set:

    mail::server_label: 'My awesome mail server'
    mail::enable_antispam: true
    mail::enable_graylisting: false
    mail::virtual_domains:
     - example.com
    mail::virtual_addresses:
      'nickname@example.com': 'user'
      'user@example.com': 'user'

Refer to `manifests/params.pp` for details on all the configuration options,
their default params and more.


In addition to the Puppet configuration, it's important that you get your DNS
configuration correct.

You need both forward and reverse DNS in order to get the SSL/TLS cert and also
to ensure major email providers will accept your messages.

    $ host mail.example.com
    mail.example.com has address 10.0.0.1

    $ host 10.0.0.1
    1.0.0.10.in-addr.arpa domain name pointer mail.example.com.


For each domain being served, you need to setup MX records and also a TXT 
record for SPF:

    $ host -t MX example.com
    example.com mail is handled by 10 mail.example.com.
    
    $ host -t TXT example.com
    example.com descriptive text "v=spf1 mx -all"

Note that SPF used to have it's own DNS type, but that was replaced in favour
of just using TXT.

For details about what values can do into an SPF record, please refer to the 
[OpenSPF website](http://www.openspf.org/SPF_Record_Syntax). The example above
tells other mail servers that whatever system is mentioned in the MX record is
a legitmate mail server for that domain.



# Security

## Firewalling

This module does not provision a firewall. You will want to set one up with
the following ports:

| Port | Allow From   | Used by                                       |
|------|--------------|-----------------------------------------------|
| 25   | Public       | Must be open to the world for receiving email |
| 143  | Trusted Only | Dovecot for STARTTLS IMAP connections         |
| 587  | Trusted Only | PostFix for authenticated email sending       |
| 993  | Trusted Only | Dovecot for SSL/TLS IMAPS connections         |

Any ports marked `Trusted Only` should be locked down to IP ranges you trust.
Whilst authentication is always required to read or send email, if you leave
these ports open to the public web, you do run the risk of attackers trying to
brute force your passwords and gain access.

Port `25` is the exception, which *must* be open for the public web in order to
actually recieve any emails.

Recommended approaches include whitelisting IP ranges or using a VPN system
like [puppet-roadwarrior](https://github.com/jethrocarr/puppet-roadwarrior).


## User Management

This module uses PAM for authenticating users, which means any system user with
a shell will have their own mailbox. If you need a good module for setting up 
these user accounts, please check out
[puppet-virtual_user](https://github.com/jethrocarr/puppet-virtual_user) which
makes it easy to define users whom will only exist on your mailserver and
nowhere else.


## SSL/TLS

This module only configures an SSL/TLS secured mail server and cannot be
disabled. This is because we don't want to risk anyone accessing their email
in an unencrypted form across the public web. To provide legitmate certs, we
use LetsEncrypt.


# Mail Filtering Rules

This module sets up Dovecot with Pigeonhole/Sieve which allows users to define
server-side mail filtering rules per-account by creating a file in
`~/.dovecot.sieve`.

The syntax is documented at http://wiki2.dovecot.org/Pigeonhole/Sieve

After making a change, syntax can be validated by building the configuration file
in the user's home directory with:

    $ sievec .dovecot.sieve

This module sets up Pigeonhole/Sieve, but does not manage the per-user rules.


# Limitations

1. This modules assumes that your mail server is not also a webserver. If you are
   running a webserver on the same server, it will cause issues with the
   LetsEncrypt/CertBot renewal process by default. See `params.pp` for options.

2. Whilst this module will setup a decent mail server, other factors like the
   type of mail you send and the reputational score of your IP address will
   have an impact on your ability to successfully deliver email to people.

3. Not all systems are great for sending mail. Residential ISPs often block
   their customers from sending email on port 25 and often lack any ability
   to setup reverse DNS. If you get stuck and your current provider doesn't
   meet the scratch, for personal mail servers recommend just getting
   [a small DigitalOcean box](https://www.digitalocean.com/?refcode=832283770cf7)

4. There is currently a known bug where Postfix needs to be restarted manually
   after the very first inital Puppet run. You can do this by executing
   `server postfix restart`. Failure to do so results in Postfix not listening
   on anything other than loopback interface.

5. Some mail clients struggle to configure initially since they try to do
   things like authenticate against port 25 (which we deny) or use insecure 
   protocols like IMAP. Usually configuring them in advanced mode will work OK.


# Troubleshooting

## Unknown user bounce

Q. When attempting to send emails to my user accounts, I get this error:

     status=bounced (user unknown)

A. You have not configured any `virtual_addresses`. Every email address that
you wish to recieve mail on, must be defined in that hash - even if the email
is the same as user@servername.


## 450 cannot find your hostname

Q. I'm unable to send email and all I see i my logs is:

    450 4.7.1 Client host rejected: cannot find your hostnam

A. This indicates that your reverse DNS is not configured correctly.


## My email client keeps giving me invalid auth on send

Q. When I try to send emails from a mail client using this server, I get
authentication errors, yet I know my creds are correct.

A. Make sure your email client is trying to use the submission port (587)
rather than port 25.



# Contributions

All contributions are welcome via Pull Requests including documentation fixes
or compatability fixes for other distributions/operating systems.

Note that this module is intentionally designed to be simple, PRs that make the
module overly complex (eg alternative MTA, use of SQL DBs) may be declined in
order to keep the module in line with the goal of supporting personal
mailservers.


# License

This module is licensed under the Apache License, Version 2.0 (the "License").
See the LICENSE or http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

