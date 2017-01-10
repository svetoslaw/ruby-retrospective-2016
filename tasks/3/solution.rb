class CommandParser
  def initialize(command_name)
    @command_name = command_name
    @command_args = []
    @options = {}
    @args_help = "Usage: #{@command_name}"
    @options_help = ''
  end

  def argument(name, &block)
    @command_args << block
    @args_help << " [#{name}]"
  end

  def option(short_name, full_name, help_text, &block)
    @options[short_name] = block
    @options[full_name] = block
    @options_help << "\n    -#{short_name}, --#{full_name} #{help_text}"
  end

  def option_with_parameter(short_name, full_name, help_text, param, &block)
    @options[short_name] = block
    @options[full_name] = block
    @options_help << "\n    -#{short_name}, --#{full_name}=#{param} "
    @options_help << help_text
  end

  def parse(command_runner, argv)
    command_args_dup = @command_args.dup
    argv.each do |argument|
      block_caller(argument, command_runner, command_args_dup)
    end
  end

  def help
    @args_help + @options_help
  end

  private
  def block_caller(argument, command_runner, command_args)
    if argument[0..1] == '--'
      full_name_option_call(argument, command_runner)
    elsif argument[0] == '-'
      short_name_option_call(argument, command_runner)
    else
      command_args.shift.call(command_runner, argument)
    end
  end

  def full_name_option_call(argument, command_runner)
    call_parameters = argument[2..-1].split('=')
    if @options.key?(call_parameters[0])
      call_parameters[1] = true unless call_parameters[1]
      @options[call_parameters[0]].call(command_runner, call_parameters[1])
    end
  end

  def short_name_option_call(argument, command_runner)
    option_name = argument[1]
    if @options.key?(option_name)
      option_value = argument[2..-1]
      option_value = true if option_value == ''
      @options[option_name].call(command_runner, option_value)
    end
  end
end