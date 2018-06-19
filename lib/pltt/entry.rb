class Pltt::Entry
  attr_reader :id, :project, :start, :stop, :resource
  attr_writer :start, :stop

  def self.from_resume(other_entry)
    new('project' => other_entry.project, 'resource' => other_entry.resource, 'start' => Time.now.utc.iso8601)
  end

  def self.create_new_for_gitlab_issue(project, issue)
    entry = Pltt::Entry.new('project' => project, 'resource' => { 'id' => issue.iid, 'type' => 'issue' }, 'start' => Time.now.utc.iso8601)
    entry.persist!
    entry
  end

  def initialize(json)
    @id = json['id']
    @project = json['project']
    @resource = json['resource']
    @notes = json['notes'] || []
    @start = Time.iso8601(json['start']) if json['start']
    @stop =  if json['stop']
               Time.iso8601(json['stop'])
             else
               false
             end
    @_json = json
  end

  def current?
    !@stop
  end

  def status
    duration = duration_time.strftime("%H:%M:%S")
    <<~DOC
      #{@project}##{iid}, #{duration.green} (id: #{@id})
      #{url.gray}
    DOC
  end

  def duration_time
    Time.at(duration_seconds).utc
  end

  def duration_seconds
    (@stop || Time.now.utc) - @start.utc
  end

  def url
    "#{Pltt::Actions::Base.config['gitlab_url']}/#{@project}/issues/#{iid}"
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
    require 'oj'
    Oj.mimic_JSON
    unless @id
      require 'hashids'
      @id = Hashids.new('', 9).encode(@start.to_i)
    end
    output = JSON.pretty_generate(id: @id,
                                  project: @project,
                                  resource: @resource,
                                  notes: @notes,
                                  start: @start && @start.iso8601,
                                  stop: @stop && @stop.iso8601)
    File.write(frame_path, output)
    unless @stop
      puts "Started:"
    end
    puts status
  end

  def add_note(id, time)
    @notes ||= []
    @notes << { id: id, time: time }
  end

  def iid
    @resource['id']
  end

  def synced?
    @notes && @notes.length > 0
  end
end
