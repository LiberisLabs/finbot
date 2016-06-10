module.exports.Config = {
  appveyor: {
    token: process.env.APPVEYOR_TOKEN
    account: process.env.APPVEYOR_ACCOUNT,
    webhook: {
      username: process.env.APPVEYOR_WEBHOOK_USERNAME,
      password: process.env.APPVEYOR_WEBHOOK_PASSWORD
    }
  },
  announce_channel: "#finbot-announce"
}