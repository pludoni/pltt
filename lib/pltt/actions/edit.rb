require_relative './base'
class Pltt::Actions::Edit < Pltt::Actions::Base
  def run(id)
    if id
      raise NotImplementedError
    else
      exit_if_not_running!
      c = current_entry
      c.frame_path

      exec ENV['EDITOR'] || 'vim', c.frame_path
    end
  end
end
