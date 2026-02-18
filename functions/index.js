const { onCall } = require("firebase-functions/v2/https");

exports.getApiKey = onCall(async (request) => {
  return { apiKey: process.env.ANTHROPIC_API_KEY };
});