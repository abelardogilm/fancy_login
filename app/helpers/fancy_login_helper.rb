module FancyLoginHelper
  def fancy_users_count
    users = $redis_sessions.get('CAM_total_registrations').to_i
    "Únete a nuestra comunidad de #{users} consumidores inteligentes"
  rescue Redis::CannotConnectError
    'Crea tu cuenta en Kelisto TETE'
  end
end
