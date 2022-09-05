const { addMarkdown } = require("./core/api/doc/addMarkdown");
const {
  headersAddDoc,
  spaceInfo,
  headersDelDoc,
  headersBase,
} = require("./core/config");

const { Command } = require("commander");
const { deleteDoc } = require("./core/api/doc/deleteDoc");
const { listDocs } = require("./core/api/doc/listDocs");

const program = new Command();

program
  .command("list")
  .option("-n, --filterName <string>", "filter docs by name (regex supported)")
  .option("-t, --onlyToken", "return only wiki_token of docs")
  .action(async (opts) => {
    console.log(await listDocs(headersBase, opts.filterName, opts.onlyToken));
  });

program
  .command("add")
  .argument("<string>", "file path")
  .option('-k, --fileKey <string>', "file key, i.e. file name to show in sidebar")
  .option("-t, --onlyToken", "return only wiki_token of docs")
  .action(async (fp, opts) => {
    console.log(`adding file path://${fp}`);
    const res = await addMarkdown(
      fp,
      headersAddDoc,
      spaceInfo.mountNodeToken,
      opts.fileKey
    );
    const data = res.data;
    console.log("added:", opts.onlyToken ? data.extra.node_token : res);
  });

program
  .command("del")
  .option("-t, --token <string>", "delete file of specific token")
  .option(
    "-n, --filterName <string>",
    "delete files of names (regex supported)"
  )
  .action(async (opts) => {
    async function deleteDocOfToken(wiki_token) {
      console.log(`deleting file of token: ${wiki_token}`);
      const docInfo = {
        space_id: spaceInfo.space_id,
        synergy_uuid: spaceInfo.synergy_uuid,
        wiki_token,
      };
      return await deleteDoc(spaceInfo.urlDelDoc, headersDelDoc, docInfo);
    }

    if (opts.wiki_token !== undefined && opts.filterName !== undefined) {
      throw new Error("mutex error");
    }
    if (opts.wiki_token) {
      await deleteDocOfToken(opts.wiki_token);
    }
    if (opts.filterName) {
      const filteredDocs = await listDocs(headersBase, opts.filterName, true);
      console.log(`found ${filteredDocs.length} matched docs`);
      for (const doc of filteredDocs) {
        // console.log({ doc });
        console.log(await deleteDocOfToken(doc.wiki_token));
      }
    }
  });

program.parse(process.argv);
