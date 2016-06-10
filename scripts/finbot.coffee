# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

Config = {
  appveyor: {
    token: process.env.APPVEYOR_TOKEN
    account: process.env.APPVEYOR_ACCOUNT,
    webhook: {
      token: process.env.APPVEYOR_WEBHOOK_TOKEN
    }
  },
  announce_channel: "#finbot-announce"
}

module.exports = (robot) ->

  robot.respond /hello/i, (res) ->
    res.reply "Yeah, hello etc"
  
  robot.respond /start build (.*)/i, (res) ->
    projectSlug = res.match[1]

    body = JSON.stringify
      accountName: Config.appveyor.account
      projectSlug: projectSlug

    robot.http("https://ci.appveyor.com/api/builds")
      .header('Authorization', "Bearer #{Config.appveyor.token}")
      .header('Content-Type', 'application/json')
      .header('Accept', 'application/json')
      .post(body) (err, resp, body) ->
        if err? then return res.reply "Got an error: #{err}"

        o = JSON.parse body
        
        link = "https://ci.appveyor.com/project/#{Config.appveyor.account}/#{projectSlug}/build/#{o.version}"

        # create the message with attachment object
        msgData = {
          channel: res.message.room
          text: "Build started"
          attachments: [
            {
              fallback: "Started build of '#{projectSlug}' v#{o.version}: #{link}",
              title: "Started build of '#{projectSlug}'",
              title_link: link
              text: "v#{o.version}"
              color: "#7CD197"
            }
          ]
        }

        # post the message
        robot.adapter.customMessage msgData

        # res.reply "Started build of '#{projectSlug}' v#{o.version}: #{link}"

        robot.brain.set "#{projectSlug}/#{o.version}", JSON.stringify({username: res.message.user.name})

  robot.router.post '/hubot/appveyor/webhook', (req, res) ->
    auth = req.headers.authorization
    return res.send 403 unless auth == Config.appveyor.webhook.token

    data = if req.body.payload? then JSON.parse req.body.payload else req.body
    outcome = if data.eventName == 'build_success' then 'succeeded' else 'failed' 
    
    msg = "Build v#{data.eventData.buildVersion} of '#{data.eventData.projectName} #{outcome}."
    value = robot.brain.get "#{data.eventData.projectName}/#{data.eventData.buildVersion}"
    if value
      o = JSON.parse(value)
      msg += " @#{o.username}"

    robot.messageRoom Config.announce_channel, msg

    res.send 'OK'

  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
