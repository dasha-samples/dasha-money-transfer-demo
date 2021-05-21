const dasha = require("@dasha.ai/sdk");
const fs = require("fs");

async function main() {
  const app = await dasha.deploy("./app");

  app.ttsDispatcher = () => "dasha";

  app.connectionProvider = async (conv) =>
    conv.input.phone === "chat"
      ? dasha.chat.connect(await dasha.chat.createConsoleChat())
      : dasha.sip.connect(new dasha.sip.Endpoint("default"));

  app.setExternal("transfer_money", async ({ amount }) => {
    amount = Number.parseInt(amount);
    return amount <= 800;
  });

  app.setExternal("resolve_source_account", async ({ info }) => {
    if (typeof info !== "string") {
      info = info.reduce((p, c) => `${p}${c.value}`, "");
    }

    info = info.replace(/ /g, "");

    switch (info) {
      case "savings":
        return `savings account ending 4455`;
      case "deposit":
        return `deposit account ending 3321`;
      default:
        throw new error(JSON.stringify(info));
    }
  });

  app.setExternal("resolve_target_account", async ({ info }) => {
    if (typeof info !== "string") {
      info = info.reduce((p, c) => `${p}${c.value}`, "");
    }

    info = info.replace(/[ _]/g, "");

    const variants = [
      "savings account ending 3321",
      "Wells Fargo account ending 9241",
      "Bank of America account ending 4879",
    ];

    const result = variants.find((x) => x.toLowerCase().replace(/ /g, "").includes(info));
    if (result === undefined) throw new Error(JSON.stringify(info));

    return result;
  });

  app.setExternal("get_target_accounts", () => [
    "savings account ending 3321",
    "Wells Fargo account ending 9241",
    "Bank of America account ending 4879",
  ]);

  await app.start();

  const conv = app.createConversation({
    phone: process.argv[2],
    depositNumber: "4455",
    savingsNumber: "3321",
  });

  if (conv.input.phone !== "chat") conv.on("transcription", console.log);

  const logFile = await fs.promises.open("./log.txt", "w");
  await logFile.appendFile("#".repeat(100) + "\n");

  conv.on("transcription", async (entry) => {
    await logFile.appendFile(`${entry.speaker}: ${entry.text}\n`);
  });

  conv.on("debugLog", async (event) => {
    if (event?.msg?.msgId === "RecognizedSpeechMessage") {
      const logEntry = event?.msg?.results[0]?.facts;
      await logFile.appendFile(JSON.stringify(logEntry, undefined, 2) + "\n");
    }
  });

  const result = await conv.execute();
  console.log(result.output);

  await app.stop();
  app.dispose();

  await logFile.close();
}

main();
