FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN npm install -g netlify-cli node-jq serve
# example of linux install
# RUN apt update && apt install jq -y