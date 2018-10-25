#begin install
sudo apt update
sudo apt install -y python3-pip python3-dev nginx
sudo pip3 install virtualenv

mkdir ~/test1
cd ~/test1
virtualenv test1env
source test1env/bin/activate

#run these commands in venv 
pip install gunicorn flask requests

nano ~/test1/test1.py
#use the following
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "<h1 style='color:red'>test1 placeholder</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0')
#
    
    
nano ~/test1/wsgi.py
#use the following
from test1 import app

if __name__ == "__main__":
    app.run()
#  
    #exit venv      
    deactivate

    
    
sudo nano /etc/systemd/system/test1.service
#use the following
[Unit]
Description=Gunicorn instance to serve test1
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/test1
Environment="PATH=/home/ubuntu/test1/test1env/bin"
ExecStart=/home/ubuntu/test1/test1env/bin/gunicorn --workers 3 --bind unix:test1.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
#


sudo systemctl start test1
sudo systemctl enable test1
sudo nano /etc/nginx/sites-available/test1
#use the following
server {
    listen 80;
    server_name test1.marealtor.com;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/ubuntu/test1/test1.sock;
    }
}
#


sudo ln -s /etc/nginx/sites-available/test1 /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx 
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt update
sudo apt upgrade -y
sudo apt install -y python-certbot-nginx
sudo systemctl reload nginx
sudo certbot --nginx -d test1.marealtor.com
#manual input
sudo systemctl restart test1
sudo systemctl restart nginx 


###### SUBSEQUENT VENVS / 2LDOMAINS #########

cd /home/ubuntu
mkdir ~/test2
cd ~/test2
virtualenv test2env
source test2env/bin/activate

#run these commands in venv 
pip install gunicorn flask requests

nano ~/test2/test2.py
#use the following
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "<h1 style='color:red'>test2 placeholder</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0')
#
    
    
nano ~/test2/wsgi.py
#use the following
from test2 import app

if __name__ == "__main__":
    app.run()
#  
    #exit venv      
    deactivate

    
    
sudo nano /etc/systemd/system/test2.service
#use the following
[Unit]
Description=Gunicorn instance to serve test2
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/test2
Environment="PATH=/home/ubuntu/test2/test2env/bin"
ExecStart=/home/ubuntu/test2/test2env/bin/gunicorn --workers 3 --bind unix:test2.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
#


sudo systemctl start test2
sudo systemctl enable test2
sudo nano /etc/nginx/sites-available/test2
#use the following
server {
    listen 80;
    server_name test2.marealtor.com;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/ubuntu/test2/test2.sock;
    }
}
#


sudo ln -s /etc/nginx/sites-available/test2 /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx 
sudo add-apt-repository -y ppa:certbot/certbot

sudo systemctl reload nginx
sudo certbot --nginx -d test2.marealtor.com
#manual input 2
sudo systemctl restart test2
sudo systemctl restart nginx 




