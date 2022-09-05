const fs = require("fs");
const path = require("path");
const { getChecksumFromFile } = require("../../algo/getChecksum");
const { getFileSize } = require("../../utils/getFileSize");

function getUrl(filePath, fileKey, mountNodeToken) {
  let fileSize = getFileSize(filePath);
  let fileChecksum = getChecksumFromFile(filePath);
  // console.log({ filePath, fileKey, fileSize, fileChecksum, mountNodeToken });
  const url =
    "https://internal-api-drive-stream.feishu.cn/space/api/box/stream/upload/all/" +
    `?name=${fileKey}` +
    `&size=${fileSize}` +
    `&checksum=${fileChecksum}` +
    `&mount_node_token=${mountNodeToken}` +
    "&mount_point=wiki" +
    "&push_open_history_record=0" +
    "&ext%5Bextra%5D=" +
    "&size_checker=true";
  return url;
}

/**
 *
 * @param filePath
 * @param headers
 * @param mountNodeToken: TODO: generate it
 * @param fileKey
 * @returns {Promise<void>}
 */
async function uploadMarkdown(
  filePath,
  headers,
  mountNodeToken,
  fileKey = undefined
) {
  const fileContent = fs.readFileSync(filePath, { encoding: "utf-8" });
  if (undefined === fileKey) {
    //  use fileName from filePath
    fileKey = path.basename(filePath);
  }
  const boundary = headers["content-type"].split("----")[1];
  const res = await fetch(getUrl(filePath, fileKey, mountNodeToken), {
    headers: headers,
    body:
      `------${boundary}\nContent-Disposition: form-data; name="file"; filename="${fileKey}"\nContent-Type: text/markdown\n\n` +
      fileContent +
      `\n------${boundary}--\n`,
    method: "POST",
  });
  const data = await res.json();
  return data;
}

module.exports = {
  uploadMarkdown,
};
