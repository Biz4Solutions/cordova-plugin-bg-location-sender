#!/usr/bin/env node

const fs = require('fs');
const version = require('./package.json').version;

let data = fs.readFileSync('./plugin.xml', "utf8");
data = data.replace(/plugin id="cordova-plugin-bg-location-sender" version="[^"]+"/, `plugin id="cordova-plugin-bg-location-sender" version="${version}"`);
fs.writeFileSync('./plugin.xml', data);
