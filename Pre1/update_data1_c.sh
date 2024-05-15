## Change Permission in folder
sudo rm -rf  /srv/shiny-server/Pre1
sudo mkdir /srv/shiny-server/Pre1


## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Pre1

### Update files
sudo rsync -a --recursive  /home/rstudio/Tableros/Pre1/ /srv/shiny-server/Pre1 --delete

## Change Permission in folder
sudo chown -R shiny:shiny /srv/shiny-server/Pre1

### refresh shiny-server
sudo systemctl stop shiny-server
sudo systemctl start shiny-server
