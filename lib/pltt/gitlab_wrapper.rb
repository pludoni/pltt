class Pltt::GitlabWrapper
  def initialize(url, token, project)
    require 'gitlab'
    @project = project

    Gitlab.endpoint = url
    Gitlab.private_token = token
  end

  def issues(scope: 'assigned-to-me', order_by: 'updated_at', state: 'opened', label: nil)
    Gitlab.issues(@project, state: state, order_by: order_by, scope: scope, labels: label ? label : nil).auto_paginate
  end

  def issue(id)
    Gitlab.issue(@project, id)
  end

  def create_issue(title, description, labels)
    user_id = Gitlab.user.id
    Gitlab.create_issue(@project, title, description: description, labels: labels.join(','), assignee_ids: [user_id])
  end

  def labels
    Gitlab.labels(@project)
  end
end
