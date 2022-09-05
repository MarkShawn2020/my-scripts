const { headersDelDoc, spaceInfo } = require("../../config");

async function deleteDoc(url, headers, docInfo) {
  let body = JSON.stringify({ ...docInfo, auto_delete_mode: 0 });
  return await (
    await fetch(url, {
      headers,
      body,
      method: "POST",
    })
  ).json();
}

module.exports = {
  deleteDoc,
};

if (require.main === module) {
  const docInfo = {
    space_id: spaceInfo.space_id,
    synergy_uuid: spaceInfo.synergy_uuid,
    wiki_token: "wikcnAj7hsoJNmMoqTlNugcOOeg",
  };

  deleteDoc(docDelUrl, headersDelDoc, docInfo);
}
