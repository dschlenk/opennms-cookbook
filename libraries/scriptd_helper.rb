class ScriptdConfig
  attr_reader :engine, :start_script, :stop_script, :reload_script, :event_script, :transactional

  def initialize(engine: nil, start_script: nil, stop_script: nil, reload_script: nil, event_script: nil, transactional: nil)
    @engine = engine || []
    @start_script = start_script || []
    @stop_script = stop_script || []
    @reload_script = reload_script || []
    @event_script = event_script || []
    @transactional = transactional
  end

  def add_engine(engine)
    if engine.is_a?(Hash)
      engine = ScriptEngine.new(
        language: engine[:language],
        class_name: engine[:class_name],
        extensions: engine[:extensions]
      )
    end
    @engine << engine
  end

  def add_script(language:, script:, type:, uei: nil)
    case type
    when 'start'
      add_start_script(StartScript.new(language: language, script: script))
    when 'stop'
      add_stop_script(StopScript.new(language: language, script: script))
    when 'reload'
      add_reload_script(ReloadScript.new(language: language, script: script))
    when 'event'
      add_event_script(EventScript.new(language: language, script: script, uei: uei))
    end
  end

  def delete_script(language:, script:, type:, uei: nil)
    case type.to_sym
    when :start
      @start_script.delete_if { |s| s.language == language && s.script == script }
    when :stop
      @stop_script.delete_if { |s| s.language == language && s.script == script }
    when :reload
      @reload_script.delete_if { |s| s.language == language && s.script == script }
    when :event
      @event_script.delete_if do |s|
        s.language == language &&
          s.script == script &&
          Array(s.uei).sort == Array(uei).sort
      end
    else
      raise ArgumentError, "Unsupported script type: #{type}"
    end
  end

  def add_start_script(script)
    @start_script << script
  end

  def add_stop_script(script)
    @stop_script << script
  end

  def add_reload_script(script)
    @reload_script << script
  end

  def add_event_script(script)
    @event_script << script
  #   Chef::Log.warn("Added #{script} to @event_script which is now #{@event_script}")
  end

  def write(file_path)
    doc = REXML::Document.new
    root = doc.add_element('scriptd-configuration')

    @engine.each do |engine|
      engine_elem = root.add_element('engine')
      engine_elem.attributes['language'] = engine.language
      engine_elem.attributes['class_name'] = engine.class_name
      engine_elem.attributes['extensions'] = engine.extensions
    end

    @start_script.each do |script|
      script_elem = root.add_element('start-script')
      script_elem.attributes['language'] = script.language
      script_elem.text = script.script
    end

    @stop_script.each do |script|
      script_elem = root.add_element('stop-script')
      script_elem.attributes['language'] = script.language
      script_elem.text = script.script
    end

    @reload_script.each do |script|
      script_elem = root.add_element('reload-script')
      script_elem.attributes['language'] = script.language
      script_elem.text = script.script
    end

    @event_script.each do |script|
      event_elem = root.add_element('event-script')
      event_elem.attributes['language'] = script.language
      script.uei.each { |uei| event_elem.add_element('uei').text = uei }
      event_elem.add_element('script').text = script.script
    end

    File.open(file_path, 'w') { |file| doc.write(file, 2) }
  end

  def eql?(other)
    self.class.eql?(other.class) &&
      @engine.eql?(other.engine) &&
      @start_script.eql?(other.start_script) &&
      @stop_script.eql?(other.stop_script) &&
      @reload_script.eql?(other.reload_script) &&
      @event_script.eql?(other.event_script) &&
      @transactional.eql?(other.transactional)
  end
end
