#!/usr/bin/env node
/**
 * install_assets.js
 * Copies Bootstrap and jQuery from node_modules into app/assets/
 * Run: npm install && node install_assets.js
 */
const fs = require('fs');
const path = require('path');

const pairs = [
  ['node_modules/bootstrap/dist/css/bootstrap.min.css', 'assets/css/bootstrap.min.css'],
  ['node_modules/bootstrap/dist/js/bootstrap.bundle.min.js', 'assets/js/bootstrap.bundle.min.js'],
  ['node_modules/jquery/dist/jquery.min.js', 'assets/js/jquery.min.js'],
];

for (const [src, dest] of pairs) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
  console.log(`Copied ${src} → ${dest}`);
}
console.log('Assets installed successfully.');
