require_relative './base'
class Pltt::Actions::Status < Pltt::Actions::Base
  def run
    exit_if_not_running!
    puts current_entry.status

    if (iid = current_entry.resource['id'])
      issue = gitlab_api.issue(iid, project: current_entry.project)
      puts "-------------------------------------------".black
      puts <<~DOC
        #{issue.title.green} (##{iid})
        #{issue.time_stats.human_total_time_spent&.dark_gray}            #{issue.assignees.map { |i| "@#{i['username']}".blue }.join(' ')}
        #{issue.labels.map { |i| "[~#{i}]".red }.join(' ')}     #{issue.milestone&.title&.magenta}

        #{issue.description}
      DOC
    end
  end
end
