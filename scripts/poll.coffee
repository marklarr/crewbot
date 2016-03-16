# Description:
#   Braintree poll
#
# Commands:
#   dog start poll <question> - Start a poll
#   dog vote <vote> - Register a vote
#   dog poll [status] - Show current poll
#   dog end poll - End the current poll

class Poll
  constructor: (@title, @votes) ->

  summary: ->
    yeas = (v for _, v of @votes when v > 0).length
    nays = (v for _, v of @votes when v < 0).length
    abst = (v for _, v of @votes when v == 0).length

    "Yea: #{yeas}\nNay: #{nays}\nAbstain: #{abst}"

module.exports = (robot) ->
  robot.respond /start poll +(.+)/i, (msg) ->
    title = msg.match[1]
    poll = robot.brain.data.poll

    if poll
      msg.send("Already running \"#{poll.title}\"")
    else
      robot.brain.data.poll = new Poll(title, {})
      msg.send("Started poll \"#{title}\"")

  robot.respond /(current *)?poll( ?status)?/i, (msg) ->
    poll = robot.brain.data.poll

    if poll
      msg.send("\"#{poll.title}\"\n#{poll.summary()}")
    else
      msg.send("No current poll.")

  robot.respond /(stop|end).*poll/i, (msg) ->
    poll = robot.brain.data.poll

    if poll
      delete robot.brain.data.poll
      msg.send("Ended \"#{poll.title}\"\nResults:\n#{poll.summary()}")
    else
      msg.send("No current poll to end.")

  robot.respond /vote +(yes|yeah?|sure|yup|ok|\+1)/i, (msg) ->
    poll = robot.brain.data.poll

    if poll
      poll.votes[msg.message.user.id] = 1
      msg.send(":+1:")
    else
      msg.send("No current poll to vote on.")

  robot.respond /vote +(no|nay|nope|\-1)/i, (msg) ->
    poll = robot.brain.data.poll

    if poll
      poll.votes[msg.message.user.id] = -1
      msg.send(":-1:")
    else
      msg.send("No current poll to vote on.")

  robot.respond /vote +(abstain|i don'?t care|whatever|indifferent)/i, (msg) ->
    poll = robot.brain.data.poll

    if poll
      poll.votes[msg.message.user.id] = 0
      msg.send(":neutral_face:")
    else
      msg.send("No current poll to vote on.")
