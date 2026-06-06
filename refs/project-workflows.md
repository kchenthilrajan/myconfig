# Project Workflows

## valtix-frontend (React, Node v18)

```bash
cd ~/valtix-frontend
nvm use v18
cp ~/Downloads/env.development.local .env.development.local
cp ~/Downloads/npmrc .npmrc
source .env.development.local
sh clean_build.sh
npm run start
```

---

## netsec-backdraft (Node v20, yarn)

```bash
cd ~/netsec-backdraft
nvm use v20
source .env.development.local
yarn
yarn build
sh tools/push.sh fmc          # deploy to FMC device
```

---

## pinacl-accelerate-ui (Node v22)

```bash
cd ~/pinacl-accelerate-ui
git checkout <branch>
cd pinecone/ui
nvm use v22
npm install
cd ../../shared && npm install
cd ../../cli && node index.js
```

---

## cspe-scc-ui-shell (Node v22)

```bash
cd ~/cspe-scc-ui-shell
nvm use v22
npm install
npm start
```

---

## cdo-platform-python-modules / agent-builder-api (Python, Poetry)

```bash
cd ~/cdo-platform-python-modules/apps/agent-builder-api
pyenv shell 3.11.15
poetry env use 3.11
poetry install
ENV=local AGENT_BUILDER_MONGODB_URL="mongodb://lockhartappuser:qgz9Mbd4q7zAMRNcYetJ@localhost:27017/?authSource=admin" poetry run python -m app.main
```

---

## ai-app-template (Python, Poetry, make)

```bash
cd apps/ai-app-template
poetry env use 3.11
poetry install
make run
```

---

## Artifactory Auth Setup

```bash
# Fetch and set auth token
curl -u "chenthil:<API_KEY>" https://artifactory.devhub-cloud.cisco.com/artifactory/api/npm/auth
export ARTIFACTORY_CLOUD_AUTH="<base64_token>"
npm config set //artifactory.devhub-cloud.cisco.com/artifactory/api/npm/npm/:_auth=$ARTIFACTORY_CLOUD_AUTH

# Set registry for cisco packages
npm config set @ciscodesignsystems:registry https://artifactory.devhub-cloud.cisco.com/artifactory/api/npm/npm/
```

---

## AWS / Duo SSO

```bash
duo-sso                                                      # refresh Cisco SSO session
export AWS_PROFILE=bedrock_api
aws sts get-caller-identity                                  # verify identity
aws configure set region us-east-2 --profile bedrock_api
```

---

## FMC / Perforce Java Build (Maven + GWT)

```bash
# Set Java version
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home

# Full Maven build from devenv/
cd proxy && mvn clean install && \
  cd ../tools && mvn clean install && \
  cd ../components && mvn clean install && \
  cd ../apps/ && mvn clean install && \
  cd ../ && mvn clean install usm-tools:runtime-jars \
  -DskipTests=true -Dmaven.test.failure.ignore=false -DtestFailureIgnore=false

# GWT dev mode
export GWT_HOME=/opt/homebrew/Cellar/gwt/2.13.0
cd usm/fmc_gwt_ui
../../gradlew usm:gwtSuperDev

# Clear Maven cache if broken
rm -rf ~/.m2/repository
```

---

## Colima + Docker

```bash
colima start                                    # start VM
colima start --cpu 4 --memory 8                 # with more resources
colima status
docker ps
docker exec -it <container_id> bash
colima stop
```

---

## SSH Hosts

```bash
ssh chenthil          # personal machine
ssh fmc               # FMC device
ssh -p 9992 admin@s90s01v005-vrouter.cisco.com
```
