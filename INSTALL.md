# First time setup

Download and install the [latest Parallels platform packages](http://www.parallels.com/)

Download and install the latest docker-compose
```
sudo pip install --upgrade distribute
sudo pip install -U docker-compose
```

Add entries to hosts file
```
echo "127.0.0.1 sentry" | sudo tee -a /private/etc/hosts > /dev/null
```
