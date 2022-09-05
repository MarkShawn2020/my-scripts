const fs = require("fs");

const getFileSize = (fp) => {
  return fs.readFileSync(fp, { encoding: "ascii" }).length;
};

module.exports = {
  getFileSize,
};
