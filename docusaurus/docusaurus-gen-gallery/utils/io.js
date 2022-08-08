'use strict';
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : {default: mod};
  };
Object.defineProperty(exports, '__esModule', {value: true});
exports.images = exports.getFiles = void 0;
const fs_1 = __importDefault(require('fs'));
const path_1 = __importDefault(require('path'));
function getFiles(root, output = []) {
  for (let file of fs_1.default.readdirSync(root, {withFileTypes: true})) {
    if (['.DS_Store'].includes(file.name)) continue;
    // console.log('reading ' + file.name)
    const fp = path_1.default.join(root, file.name);
    if (file.isDirectory()) getFiles(fp, output);
    else output.push(fp);
  }
  return output;
}
exports.getFiles = getFiles;
const root = path_1.default.join(__dirname, '../../../static/gallery');
// for (let item of yieldFiles(root)) console.log(item)
exports.images = getFiles(root).map((s) => 'gallery' + s.slice(root.length));
