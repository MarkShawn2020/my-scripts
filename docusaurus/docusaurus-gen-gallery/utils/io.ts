/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
import fs from 'fs';
import path from 'path';

export function getFiles(root: string, output: string[] = []): string[] {
  for (let file of fs.readdirSync(root, {withFileTypes: true})) {
    if (['.DS_Store'].includes(file.name)) continue;
    // console.log('reading ' + file.name)
    const fp = path.join(root, file.name);
    if (file.isDirectory()) getFiles(fp, output);
    else output.push(fp);
  }
  return output;
}

const root = path.join(__dirname, '../../../static/gallery');
// for (let item of yieldFiles(root)) console.log(item)

export const images = getFiles(root).map(
  (s) => 'gallery' + s.slice(root.length),
);
