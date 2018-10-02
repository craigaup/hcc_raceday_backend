# Hawkesbury Canoe Classic Raceday

## Installation

Make sure Ruby 2.3 is installed.

```text
gem install bundle
gem install rails
```

Create user for running the raceday system:

```text
useradd -u 2005 -c 'Raceday Production' -m -d /home/raceday_prod -s `which bash` raceday_prod
```

On debian or ubuntu:

Add the passenger apt repository to `/etc/apt/sources.list.d/passenger.list`:

```text
deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main
```

Add the key:

```text
gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -
```

Install packages:

```text
sudo apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev libsqlite3-dev sqlite3
ruby /usr/bin/passenger-install-apache2-module --apxs2-path=/usr/bin/apxs
```

- Copy in the apache2_config_file from data to apache sites available.
- Modify to reflect file locations, port, etc
- Add in ports to /etc/apache2/ports.conf file
- Log in as raceday user

Generate put key in gitlab (should be in deploy keys):

```text
ssh-keygen -b 4096 -f .ssh/gitlab_key -N ''
```

Add following to `.ssh/config`:

```text
Host baltig.cobradah.org
    IdentitiesOnly yes
    User git
    IdentityFile /home/raceday_prod/.ssh/gitlab_keyi
    Hostname baltig.cobradah.org
    Port 22252
    ForwardX11 no
```

Clone repository:
```text
git clone git@baltig.cobradah.org:hcc/hccraceday.git
```

Create database:

```text
mysql -u root -p
```

Run this script:

```text
CREATE USER 'raceday_prod'@'localhost' IDENTIFIED BY '';
GRANT USAGE ON *.* TO 'raceday_prod';
CREATE DATABASE raceday_prod;
GRANT ALL PRIVILEGES ON raceday_prod.* TO 'raceday_prod'@'%';
```

Then:

```text
bundle install --with=mysql2:production --without=development --path vendor/gems
```

- Create server_variables.sh using server_variables.sh.template file.
- Edit and add values

Make sure to add a file in `db/seeds/.userinitialpass.rb` there is a template of what it should look like in the directory.

```text
. ./server_variables.sh && rails db:migrate
. ./server_variables.sh && rails db:seed
```

Finally, as root:

```text
a2ensite raceday_prod
service apache2 restart
```
