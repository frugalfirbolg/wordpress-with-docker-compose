A simple example of a docker-compose.yml exposed for testing with Install On Digital Ocean button

_For now just a shell script to throw into the Create Droplet pipeline._

Copy and paste the script at
```
https://raw.githubusercontent.com/frugalfirbolg/wordpress-with-docker-compose/master/user-data.sh
```
into the User Data field in the Create Droplet form:

Then wait for a couple minutes and check the console to confirm that everything ran successfully.

Logs are located in

```shell
/var/log/cloud-init-output.log
```
