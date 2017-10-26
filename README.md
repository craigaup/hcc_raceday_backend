# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

Make sure Ruby 2.3 is installed
gem install bundle
gem install rails

Create user for running the raceday system
```bash
useradd -u 2005 -c 'Raceday Production' -m -d '/home/raceday_prod' -s `which bash` raceday_prod
```

On debian or ubuntu
Add the passenger apt repository to /etc/apt/sources.list.d/passenger.list 
deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main

Add the key
gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -

--

Install git, mysql, apache2, apache2-bin, apache2-data, apache2-dev, libapache2-mod-passenger, passenger, passenger-dev, passenger-doc, nodejs
sudo apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev libsqlite3-dev sqlite3

/usr/local/bin/ruby /usr/bin/passenger-install-apache2-module --apxs2-path='/usr/bin/apxs'

copy in the apache2_config_file from data to apache sites available
modify to reflech file locations, port, etc
add in ports to /etc/apache2/ports.conf file

Log in as raceday user

Generate  put key in gitlab (should be in deploy keys)
```bash
ssh-keygen -b 4096 -f .ssh/gitlab_key -N ''
```

Add following to .ssh/config
Host baltig.cobradah.org
    IdentitiesOnly yes
    User git
    IdentityFile /home/raceday_prod/.ssh/gitlab_keyi
    Hostname baltig.cobradah.org
    Port 22252
    ForwardX11 no

Clone repository
```bash
git clone git@baltig.cobradah.org:hcc/hccraceday.git
```

Create database
mysql -u root -p
```sql
CREATE USER 'raceday_prod'@'localhost' IDENTIFIED BY '';
GRANT USAGE ON *.* TO 'raceday_prod';
create database raceday_prod;
grant all privileges on raceday_prod.* to 'raceday_prod'@'%';
```

bundle install --with=mysql2:production --without=development --path vendor/gems

Create server_variables.sh using server_variables.sh.template file
Edit and add values

Make sure to add a file in 'db/seeds/.userinitialpass.rb' there is a template of what it should look like in the directory


. ./server_variables.sh && rails db:migrate
. ./server_variables.sh && rails db:seed

As root 
a2ensite raceday_prod
service apache2 restart
