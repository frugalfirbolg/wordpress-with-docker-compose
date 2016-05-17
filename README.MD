A simple example of a docker-compose.yml exposed for testing with Install On Digital Ocean button

_For now just a shell script to throw into the Create Droplet pipeline._

Copy and paste the following into the User Data field in the Create Droplet form:
```shell
#!/bin/sh
ftpuser=ftpuser #replace with user of your choosing
ftppass=secret1! #obviously replace with a secret password, currently 8 characters or less
wget -O - https://raw.githubusercontent.com/frugalfirbolg/wordpress-with-docker-compose/master/user-data.sh | sh
```

Don't forget the __#!/bin/sh__ at the beginning or Digital Ocean will not execute the script!

Then wait for a couple minutes and check the console to confirm that everything ran successfully.

Logs are located in:
```shell
/var/log/cloud-init-output.log
```

This snippet is provided without warranty or guarantee.
