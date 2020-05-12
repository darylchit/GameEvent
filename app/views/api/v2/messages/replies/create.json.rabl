 if reply.message.message_type = 'clan_messages' && reply.message.body == 'clan_chat'
   object @clan_message
   attributes :id
 else
  if reply.persisted?
    object reply
    attributes :id
  else
    object reply
    attributes :errors
  end
end
