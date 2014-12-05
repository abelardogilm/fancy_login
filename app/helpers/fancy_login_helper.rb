module FancyLoginHelper
  def fancy_users_count
    users = number_with_delimiter(
      $redis_sessions.get('CAM_total_registrations').to_i,
      delimiter: '.'
    )
    "Únete a nuestra comunidad de #{users} consumidores inteligentes"
  rescue Redis::CannotConnectError
    'Crea tu cuenta en Kelisto'
  end
end
