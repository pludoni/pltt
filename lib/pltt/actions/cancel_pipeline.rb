require_relative './base'

class Pltt::Actions::CancelPipeline < Pltt::Actions::Base
  def run
    relevant = [] 
    gitlab_api.pipelines.each do |pipeline|
      relevant << pipeline
      if pipeline['status'] == 'success'
        break
      end
    end
    puts " Active Recent Pipelines for #{config['project']}:"
    relevant.each do |pipeline|
      puts format_pipeline(pipeline)
    end
    puts ""
    pending_states = %w[created waiting_for_resource preparing pending running]
    running_or_pending = relevant.select { |pipeline| pending_states.include?(pipeline.status) }.drop(1)
    if running_or_pending.length == 0
      puts ' Not enough running or pending pipelines to cancel.'.red
      exit 1
    end
    puts " Pending Pipelines to Cancel:"
    running_or_pending.each do |pl|
      puts format_pipeline(pl)
    end
    prompt = TTY::Prompt.new
    exit 1 unless prompt.yes?("Cancel above now?")

    running_or_pending.each do |pipeline|
      puts " Canceling #{pipeline.web_url}"
      gitlab_api.cancel_pipeline(pipeline.iid)
    end
  end

  def format_pipeline(pipeline)
    lpad = sprintf('%10s', pipeline.status)
    status_color = case pipeline.status
                   when 'success' then lpad.green
                   when 'canceled' then lpad.gray
                   when 'failed' then lpad.red
                   when 'running' then lpad.blue
                   else lpda
                   end
    "#{status_color} #{pipeline.sha} (#{pipeline.source}) #{pipeline.web_url.gray}"
  end
end
