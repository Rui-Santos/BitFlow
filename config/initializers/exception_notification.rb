BitFlow::Application.config.middleware.use ExceptionNotifier,
   :email_prefix => "[Bitflow Error] ",
   :sender_address => %{"notifier" <mail@bitflow.org>},
   :exception_recipients => %w{nila@activesphere.com niket@activesphere.com jure.vrscaj@gmail.com gabbar@activesphere.com}
