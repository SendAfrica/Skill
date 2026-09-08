import { SendAfricaClient, getSmsPartInfo } from "sendafrica";

const apiKey = process.env.SENDFRICA_API_KEY;
if (!apiKey) {
  throw new Error("Set SENDAFRICA_API_KEY in your environment first.");
}

const client = new SendAfricaClient({
  apiKey,
  baseUrl: "https://api.sendafrica.online/v1",
  maxRetries: 3,
});

async function checkBalance() {
  const balance = await client.credits.balance();
  console.log(`Balance: ${balance.balance} credits on account ${balance.accountId}`);
}

async function sendFirstSms() {
  const result = await client.sms.send({
    to: "0712345678",
    message: "Hello from SendAfrica! Your order is ready.",
    from: "MyBrand",
  }, { idempotencyKey: "order-1234" });

  console.log(`Sent: ${result.messageId} — ${result.status} — ${result.creditsUsed} credit(s)`);
  return result.messageId;
}

function analyzeMessage() {
  const info = getSmsPartInfo("Hello from SendAfrica! Your order is ready.");
  console.log(`Encoding: ${info.encoding}, Parts: ${info.parts}, Credits: ${info.creditsRequired}`);
}

async function main() {
  await checkBalance();
  analyzeMessage();
  const messageId = await sendFirstSms();
  console.log(`\nTrack delivery: GET /v1/sms/logs?search=${messageId}`);
}

main().catch((err) => {
  if (err instanceof Error && err.message.includes("insufficient_credits")) {
    console.log("Not enough credits — top up at https://app.sendafrica.online");
  } else if (err instanceof Error && err.message.includes("401")) {
    console.log("Check your API key at https://app.sendafrica.online/settings/api-keys");
  } else {
    console.error("Error:", err);
  }
});
