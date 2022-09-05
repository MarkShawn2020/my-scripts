const path = require("path");

function getFileKey(filePath) {
  return path.baseName(filePath);
}

module.exports = {
  getFileKey,
};
