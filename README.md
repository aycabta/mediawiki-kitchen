MediaWiki Kitchen
=================

In Soviet Russia, MediaWiki builds up Chef!

## Usage

You must run `scp ssl.sh hostname:~` and `ssh hostname ./ssl.sh` and input FQDN at Common Name before `knife solo cook hostname`,
if you use self-signed certificate temporary.
