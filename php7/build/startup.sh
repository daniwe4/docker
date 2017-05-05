#!/bin/bash
mkdir -p /var/www/log
mkdir -p /var/www/ilias/data/index

if [ ! -f /etc/apache2/sites-enabled/dw.conf ]; then
echo "Configure apache..."
cat << EOF > /etc/apache2/sites-enabled/dw.conf
<VirtualHost *:80>
DocumentRoot /var/www/html/dw/

<Directory /var/www/html/dw>
  Options Indexes FollowSymLinks MultiViews
  AllowOverride All
  Order allow,deny
  allow from all
</Directory>

ErrorLog /var/www/log/error.log
LogLevel warn
CustomLog /var/www/log/access.log combined
ServerSignature Off
</VirtualHost>
EOF
fi

if [ ! -f /var/www/html/ilias/ilias.ini.php ]; then
	echo "Configure InstILIAS..."
	cat << EOF > /ilias-tool-InstILIAS/src/config.yaml
---
client:
    #Directory beside the webserver. ILIAS use it to save data or files. e.g. images before upload to the webserver.
    #Example: /var/www/ilias/data/
    data_dir: /var/www/ilias/data/
    #ILIAS is a client based system. Client with this name will be created
    #Example: ACMECorp
    name: CAT06
    #It is possible to encode passwords in two ways. Enter the one you want to use. Possible encoder are 'md5' and 'bcrypt'
    password_encoder: bcrypt
    #Session life time in minutes. Default is 120.
    session_expire: 120
database:
    #Host of your database.
    host: $MYSQL_HOST
    #Name for the ILIAS database.
    database: $MYSQL_DATABASE
    #User with permissions to create database / tables
    user: $MYSQL_USER
    #Password for above user
    password: $MYSQL_PASSWORD
    #ILIAS supports three database engines. InnoDB, MyISAM, .....
    engine: innodb
    #Encoding for database
    encoding: utf8_general_ci
    # create db
    create_db: 1
language:
    #Default language ILIAS will use.
    default: de
    #Install languages user can decide to use. Default language must be listed too!
    available:
        - de
        - en
server:
    #Url ILIAS could be accessed by web browser
    #Example: https://www.example.com/ilias/
    http_path: http://$ILIAS_URL
    #Directory on the webserver ILIAS should be installed in
    #Example: /var/www/html/ilias/
    absolute_path: /var/www/html/dw/ilias/
    #Timezone for PHP
    timezone: Europe/Berlin
setup:
    #Master password to enter the setup.
    master_password: $ILIAS_MASTER_PASSWORD
tools:
    #ImageMagick is the requested image converter. It is used to create certificates. Enter the installation path
    convert: /usr/bin/convert
    #Installation path to zip
    zip: /bin/zip
    #Installation path to unzip
    unzip: /bin/unzip
    #Installation path to java
    java: /usr/bin/java
log:
    #Directory for ILIAS log file (must be writeable for webserver user)
    #Example: /var/log/ilias/
    path: /var/www/log/
    #Name of the log file
    file_name: ilias.log
    #Path to error_log
    error_log: /var/www/log/
git_branch:
    #URL of your git repository you want to install ILIAS from
    url: https://github.com/ILIAS-eLearning/ILIAS.git
    #Branch name of the release you want to use
    branch: $ILIAS_RELEASE

#With this part you are able to configure the passwors settings like number of upper or lower chars, user special chars and so on
password_settings:
    #If activated the user is forced to change his passwort after first login. You can toggle with 1 (active) or 0 (inactive)
    change_on_first_login: 1
    #At least one special char is required in password. You can toggle with 1 (active) or 0 (inactive)
    use_special_chars: 1
    #Numbers and chars are required in password. You can toggle with 1 (active) or 0 (inactive)
    numbers_and_chars: 1
    #Minimum length for the password.
    min_length: 6
    #Maximum length for the password. If set to 0 the lenght is open end.
    max_length: 0
    #Number of required upper chars
    num_upper_chars: 0
    #Number of requires lower chars
    num_lower_chars: 0
    #Value in days the password will be expired
    expire_in_days: 0
    #If active the you can see the link "Forgot Password". You can toggle with 1 (active) or 0 (inactive)
    forgot_password_aktive: 1
    #Max Number of login attemps, before account get blocked. if you enter 0 user account never will be blocked
    max_num_login_attempts: 0

#Configurate youre changings for the editor administratio part. It's possible to toggle usage of tinyMCE and configure
#repository page edit settings
editor:
    #Active the TyniMCE editor. You can toggle with 1 (active) or 0 (inactive)
    enable_tinymce: 1
    #Settings for the repository page editor. You can toggle each part with 1 (active) or 0 (inactive)
    repo_page_editor:
        enable: 0
        heavy_marked: 1
        marked: 1
        importand: 1
        superscript: 1
        subscript: 1
        comment: 1
        quote: 1
        accent: 1
        code: 1
        latex: 1
        footnote: 1
        external_link: 1
#Configure the java server. if configured ilias is able to generate pdf files and an extended search mode is activated
java_server:
    #host of running java server
    host: localhost
    #port the java server is listening
    port: 11111
    #path for saving index files
    index_path: /var/www/ilias/data/index/
    #path and name of logfile. could be the same path as ilias log
    log_file: /var/www/log/ilServer.log
    #log lever. possible DEBUG, INFO, WARN, ERROR, FATAL
    log_level: INFO
    #number of threads
    num_threads: 1
    #max size of files to get indexed. Value is given in MB
    max_file_size: 500
    #Path to create ilServer.ini
    ini_path: /var/www/ilias/data/
#Configure the ilias certificate generator. You can toggle with 1 (active) or 0 (inactive)
certificate:
    enable: 1
#ILIAS is working with SOAP. In this line it is possible to configure
soap:
    #Toggle SOAP is active or not. 1 (active) or 0 (inactive)
    enable: 1
    #Path to WSDL Files
    wdsl_path: localhost
    #Conenction timeout in seconds
    timeout: 10
EOF

# Check for MySQL-Connection...
# until mysqlshow -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE; do
#     sleep 3
# done

echo "Configure ILIAS, this might take a while."
php /ilias-tool-InstILIAS/src/bin/install.php /ilias-tool-InstILIAS/src/config.yaml non_interactiv
chown www-data:www-data /var/www -R
fi

echo "****** ILIAS default login: root:homer ******"

echo "****** Start Java Server *******"
java -Dfile.encoding=UTF-8 -jar /var/www/html/dw/ilias/Services/WebServices/RPC/lib/ilServer.jar \
/var/www/ilias/data/ilServer.ini start &

/usr/sbin/apache2ctl -D FOREGROUND