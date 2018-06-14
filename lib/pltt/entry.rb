class Pltt::Entry
  attr_reader :id, :project, :start, :stop, :resource

  def self.from_resume(other_entry)
    new('project' => other_entry.project, 'resource' => other_entry.resource, 'start' => Time.now.utc)
  end

  def initialize(json)
    @id = json['id']
    @project = json['project']
    @resource = json['resource']
    @notes = json['notes']
    @start = Time.iso8601 json['start'] if json['stop']
    @stop = Time.iso8601(json['stop']) if json['stop']
    @_json = json
  end

  def current?
    !@stop
  end

  def status
    duration = (Time.now.utc - @start.utc)
    duration = Time.at(duration).utc.strftime("%H:%M:%S")
    <<~DOC
      #{@project}##{@resource['id']}, #{duration.green} (id: #{@id})
      #{url.gray}
    DOC
  end

  def url
    "#{Pltt::Actions::Base.config['gitlab_url']}/#{@project}/issues/#{@resource['id']}"
  end

  def frame_path
    @frame_path ||= File.join(File.expand_path(Pltt::Actions::Base.config['frame_dir']), @id + ".json")
  end

  def cancel!
    if File.exist?(frame_path)
      puts "Entry deleted"
      File.unlink(frame_path)
    else
      puts "Entry already deleted!"
      exit 1
    end
  end

  def persist!
    unless @id
      require 'hashids'
      Hashids.new.encode(@start.to_s)

    end
  end
end
