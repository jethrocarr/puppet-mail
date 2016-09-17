# puppet-mail

# Overview

Running your own mail server can be a powerful and rewarding freedom, but does
tend to come with a number of challanges including just getting all the
components to work properly together in the first place, not to mention the
trickiness of security and spam filtering.

This Puppet module will build a complete fully functioning mailserver designed
for use by individuals as a personal mailserver.


# Features

* Uses Postfix as the MTA
* Uses Dovecot for providing IMAP
* Mandatory SSL/TLS configured services.
* Filters spam using SpamAssassin
* Provides Sieve for server-side email filtering rules.


# Requirements

One of the following GNU/Linux distributions:
* CentOS (7)

Include the following Puppet module dependencies in your `Puppetfile` (if using
recommended r10k workflow):

    mod 'puppetlabs/stdlib'
    mod 'stahnma/epel'
    mod 'letsencrypt',
      :git    => 'https://github.com/danzilio/puppet-letsencrypt.git',
      :branch => 'master'

Note that the letsencrypt module needs to be the upstream Github version, the
version on PuppetForge is too old.

# Usage

To provision the mailserver, simply add the following to your own modules or
`site.pp` file:

    class { 'mail': }

Naturally you'll want to do some configuration of the mailserver. This is best
done in Puppet Hiera. The following is an example of the minimum options you'd
want to se:

    TODO

Refer to `manifests/params.pp` for details on all the configuration options,
their default params and more.





# Security

## Firewalling

TODO

## User Management

This module uses PAM for authenticating users, which means any system user with
a shell will have their own mailbox. If you need a good module for setting up 
these user accounts, please check out
[puppet-virtual_user](https://github.com/jethrocarr/puppet-virtual_user) which
makes it easy to define users whom will only exist on your mailserver and
nowhere else.


## SSL/TLS

This module only configures an SSL/TLS secured mail server. This is because we
don't want to risk anyone running an unencrypted server solution across the
public web

Certs are automatically requested and provisioned using LetsEncrypt.


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

This modules assumes that your mail server is not also a webserver. If you are
running a webserver on the same server, it will cause issues with the
LetsEncrypt/CertBot renewal process.


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

