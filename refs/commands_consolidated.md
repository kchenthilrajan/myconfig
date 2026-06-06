# Consolidated Command Reference
> Deduplicated and grouped from history_04_03.out / history_04_03_2.out

---

## 1. Shell / Environment Config

```bash
vi ~/.zshrc
nvim ~/.zshrc
source ~/.zshrc
cp ~/Downloads/zshrc ~/.zshrc
mv ~/.zshrc ~/.zshrc_bakup
cp ~/.zshrc_bakup ~/.zshrc

# Add pyenv to zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Add Java to PATH
echo 'export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc

# Set AWS profile permanently
echo 'export AWS_PROFILE=bedrock_api' >> ~/.zshrc
```

---

## 2. Homebrew Installs

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install starship
brew install neovim
brew install tmux
brew install node yarn fnm watchman rsync rust
brew install plzip
brew install p7zip
brew install maven
brew install ant
brew install java
brew install openjdk@11
brew install --cask zulu@8
brew install --cask zulu@11
brew install gwt
brew install pyenv
brew install poetry

# Duo SSO
brew tap ats-operations/homebrew-tap https://wwwin-github.cisco.com/ATS-operations/homebrew-tap
brew install ats-operations/tap/duo-sso

# Cleanup
brew uninstall openjdk
brew cleanup
brew list | grep -i java
brew list --cask | grep -i zulu
```

---

## 3. SSH & Remote Access

```bash
ls ~/.ssh
cat ~/.ssh/config
nvim ~/.ssh/config
nvim config   # from ~/.ssh/

ssh chenthil
ssh fmc
ssh -p 9992 admin@s90s01v005-vrouter.cisco.com
```

---

## 4. Git Operations

```bash
git status
git pull
git branch
git remote -v
git stash
git add docs/design/ai_defense_mcp_pr_mapping.md
git checkout ACLPINACL-4182
git checkout CSF-41542-mcp-events-uev

# Clone repos
git clone org-115834518@github.com:cisco-sbg/valtix-frontend.git
git clone org-115834518@github.com:cisco-sbg/pinacl-accelerate-ui.git
git clone org-115834518@github.com:cisco-sbg/cspe-scc-ui-shell.git
git clone git@github-cisco:amsathya_cisco/mcp_visibility_ai_squad.git
git clone git@wwwin-github.cisco.com:firepower-management-center/push.git
```

---

## 5. Node.js / NVM / npm / yarn

```bash
nvm list
nvm use v16
nvm use v18
nvm use v20
nvm use v22
node -v

# npm
npm cache clean --force
npm i -f
npm install
npm run start
npm config list
npm config set @ciscodesignsystems:registry https://artifactory.devhub-cloud.cisco.com/artifactory/api/npm/npm/
npm config get @ciscodesignsystems:registry
npm config set //artifactory.devhub-cloud.cisco.com/artifactory/api/npm/npm/:_auth=$ARTIFACTORY_CLOUD_AUTH
npm config delete //engci-maven.cisco.com/artifactory/api/npm/npm/:_authToken
npm view @ciscodesignsystems/cds-react-header
npm view @ciscodesignsystems/cds-react-bar-chart
npm search ciscodesignsystems --registry=https://artifactory.devhub-cloud.cisco.com/artifactory/api/npm/npm/

# yarn
yarn
yarn build
yarn schema-types

cargo install svgcleaner
```

---

## 6. Artifactory Auth

```bash
# Fetch auth token
curl -u "chenthil:<API_KEY>" https://artifactory.devhub-cloud.cisco.com/artifactory/api/npm/auth

# Set auth env vars
export ARTIFACTORY_CLOUD_AUTH="<base64_token>"
export ARTIFACTORY_LOCAL_AUTH="<base64_token>"

# Apply to npm
npm config set //artifactory.devhub-cloud.cisco.com/artifactory/api/npm/npm/:_auth=$ARTIFACTORY_CLOUD_AUTH
```

---

## 7. valtix-frontend Dev Workflow

```bash
cd ~/valtix-frontend
nvm use v18
cp ~/Downloads/env.development.local .env.development.local
cp ~/Downloads/build.sh .
cp ~/Downloads/clean_build.sh .
cp ~/Downloads/npmrc .npmrc
source .env.development.local
sh clean_build.sh
npm run start
git pull
```

---

## 8. netsec-backdraft Dev Workflow

```bash
cd ~/netsec-backdraft
nvm use v20
source .env.development.local
yarn
yarn build
sh tools/push.sh fmc
```

---

## 9. pinacl-accelerate-ui Dev Workflow

```bash
cd ~/pinacl-accelerate-ui
git checkout ACLPINACL-4182
cd pinecone/ui
nvm use v22
npm install
cd ../../shared && npm install
cd ../../cli && node index.js
```

---

## 10. cspe-scc-ui-shell Dev Workflow

```bash
cd ~/cspe-scc-ui-shell
nvm use v22
npm install
npm start
```

---

## 11. AWS / Duo SSO

```bash
duo-sso
aws --version
aws sts get-caller-identity
aws configure set region us-east-2 --profile bedrock_api
export AWS_PROFILE=bedrock_api

# Install AWS CLI
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg ./AWSCLIV2.pkg -target /

# Config files
nvim ~/.aws/credentials
nvim ~/.aws/config
nvim ~/.config/duo-sso/config.json
cat ~/.aws/credentials
cat ~/.aws/config
cat ~/.config/duo-sso/config.json

# Reset AWS config
mv ~/.aws ~/.aws_backup
```

---

## 12. Python / Poetry / pyenv

```bash
pyenv install 3.11
pyenv shell 3.11.15
python --version
poetry --version
poetry config virtualenvs.in-project true
poetry env use 3.11
poetry install

# cdo-platform-python-modules agent builder
cd ~/cdo-platform-python-modules/apps/agent-builder-api
ENV=local AGENT_BUILDER_MONGODB_URL="mongodb://lockhartappuser:qgz9Mbd4q7zAMRNcYetJ@localhost:27017/?authSource=admin" poetry run python -m app.main

# ai-app-template
cd apps/ai-app-template
poetry env use 3.11
poetry install
make run

python3 start_agent_builder.py
```

---

## 13. Docker / Colima

```bash
colima start
colima stop
colima status
colima delete --force

docker ps
docker exec -it <container_id> bash
docker run --rm -v $PWD:/app -w /app node:20 npm install
docker run --rm -v $PWD:/app -w /app node:20 npm test
docker run -p 8080:8080 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts

# demo-cli CI
./ci.sh
```

---

## 14. Java / Maven / Gradle / GWT (Perforce FMC Build)

```bash
java -version
/usr/libexec/java_home -V
ls /Library/Java/JavaVirtualMachines/
unset JAVA_HOME

# Set Java 8
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home
# Set Java 11
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"

mvn -version

# Full Maven build (from devenv/)
cd proxy && mvn clean install && \
  cd ../tools && mvn clean install && \
  cd ../components && mvn clean install && \
  cd ../apps/ && mvn clean install && \
  cd ../ && mvn clean install usm-tools:runtime-jars \
  -DskipTests=true -Dmaven.test.failure.ignore=false -DtestFailureIgnore=false

rm -rf ~/.m2/repository

# GWT
export GWT_HOME=/opt/homebrew/Cellar/gwt/2.13.0

# Gradle (from usm/fmc_gwt_ui/)
../../gradlew usm:install
../../gradlew usm:gwtSuperDev
../../gradlew usm:gwtDev

# Copy build artifacts to IMS_10_5_MAIN
sudo cp build.gradle ~/Perforce/chenthil_IMS_10_5_MAIN/firepower/ims/IMS_10_5_MAIN/usm/fmc_gwt_ui/
sudo cp gradle.properties ~/Perforce/chenthil_IMS_10_5_MAIN/firepower/ims/IMS_10_5_MAIN/usm/fmc_gwt_ui/
sudo cp usm/build.xml ~/Perforce/chenthil_IMS_10_5_MAIN/firepower/ims/IMS_10_5_MAIN/usm/fmc_gwt_ui/usm/
sudo cp usm/war/WEB-INF/web.xml ~/Perforce/chenthil_IMS_10_5_MAIN/firepower/ims/IMS_10_5_MAIN/usm/fmc_gwt_ui/usm/war/WEB-INF/
sudo cp usm/war/sourcemaps.jsp ~/Perforce/chenthil_IMS_10_5_MAIN/firepower/ims/IMS_10_5_MAIN/usm/fmc_gwt_ui/usm/war/
```

---

## 15. Perforce (p4)

```bash
p4 client
p4 opened
p4 unshelve -s 4991925
p4 change
echo $WORKSPACE
```

---

## 16. tmux

```bash
brew install tmux
tmux
nvim ~/.tmux.conf
# set vi key mode in tmux
# set-window-option -g mode-keys vi
```

---

## 17. Process / Port Management

```bash
lsof -i :3000 2>/dev/null
ps -p 46878 -o pid,command
kill 46878
kill %%
```

---

## 18. File / Archive Operations

```bash
7z x ~/Downloads/myzip.7z .
cp ~/Downloads/env.development.local .env.development.local
rm -rf node_modules package-lock.json
rm -rf pinacl-accelerate-ui
pbcopy < ~/backup/vscode-shortcuts.txt

# Find JARs
find ~/Perforce/chenthil_10_05_MCP_INSPECTION/firepower/ims/10_5_MCP_INSPECTION/usm -iname "*.jar"
find ~/Perforce/chenthil_IMS_10_5_MAIN/firepower/ims/IMS_10_5_MAIN/ -iname "*.jar"
```

---

## 19. Changelist / Swarm Links

```bash
cd ~/backup
grep 'Changelist ID' changelists.txt | sort -u | awk '{print "https://sp4-fp-swarm.cisco.com/changes/"$3}' >> changelist.links
```
