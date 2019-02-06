# standard deployment for a flask app, microservice, or api at a second-level domain such as 'service_name.yourdomain.com'
# tested on ubuntu 18.04
# ensure your DNS A record is set up properly before starting

# find and replace:
# service_name = your service name
# yourdomain.com = your domain


# install updates and requirements 
sudo apt update
sudo apt install -y python3-pip python3-dev nginx
sudo pip3 install virtualenv

# create your service environment
mkdir ~/service_name
cd ~/service_name
virtualenv service_name_env

# activate it
source service_name_env/bin/activate

# install python modules  
pip install gunicorn flask requests

# create an application
nano ~/service_name/service_name.py

### use the following for service_name.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "<h1 style='color:red'>service_name placeholder</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0')
###
# save and close nano
    
#create a wsgi instance
nano ~/service_name/wsgi.py

### use the following for wsgi.py
from service_name import app

if __name__ == "__main__":
    app.run()
###
# save and close nano
  
#exit venv      
deactivate
    
# create a new system service for your application
sudo nano /etc/systemd/system/service_name.service

### use the following for service_name.service
[Unit]
Description=Gunicorn instance to serve service_name
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/service_name
Environment="PATH=/home/ubuntu/service_name/service_name_env/bin"
ExecStart=/home/ubuntu/service_name/service_name_env/bin/gunicorn --workers 3 --bind unix:service_name.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
###
# save and close nano

# start the service
sudo systemctl start service_name
sudo systemctl enable service_name

# add it to nginx
sudo nano /etc/nginx/sites-available/service_name

### use the following for service_name
server {
    listen 80;
    server_name service_name.yourdomain.com;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/ubuntu/service_name/service_name.sock;
    }
}
###
# save and close nano

# enable and begin serving it in nginx after a restart
sudo ln -s /etc/nginx/sites-available/service_name /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx

# set up certbot for https and restart
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt update
sudo apt upgrade -y
sudo apt install -y python-certbot-nginx
sudo systemctl reload nginx
sudo certbot --nginx -d service_name.yourdomain.com
sudo systemctl restart service_name
sudo systemctl restart nginx 
