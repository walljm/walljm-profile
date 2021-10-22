winget install --silent --id Git.Git
git config --global core.autocrlf true
git config --global user.name "jason.wall"
git config --global user.email "jason.wall@vaeit.com"
git config --global pull.rebase merges
git config --global rebase.autoStash true

Copy-Item -Path .\ssh\config -Destination "C:\Users\jason.wall\.ssh\"

ssh-keygen -t ed25519 -C "vae laptop gitlab"
cat ~/.ssh/id_ed25519.pub | clip
ssh -T git@gitlab.com

## put the ssh keys in gitlab