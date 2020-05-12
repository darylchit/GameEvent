class NotificationWorker
	# TODO SIDEKIQ
	# include Sidekiq::Worker

	def perform(object_id, klass, notification_klass, notification_method_signature)
		if !Rails.env.test?
			object = (klass.constantize).send('find', object_id)
			notification_klass.constantize.send(notification_method_signature, object)
		end
	end
end
