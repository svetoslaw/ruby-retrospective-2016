class Argument
  def initialize(name, block)
    @name = name
    @block = block
  end

  def parse(command_runner, argument)
    @block.call(command_runner, argument)
  end
end

class Option
  attr_accessor :short_name, :full_name
  def initialize(short_name, full_name, param, block)
    @short_name = short_name
    @full_name = full_name
    @parameters = param
    @block = block
  end

  def parse(command_runner, parameter = true)
    @block.call(command_runner, parameter)
  end
end

class CommandParser
  def initialize(command_name)
    @command_name = command_name
    @arguments = []
    @options = []
    @args_help = "Usage: #{@command_name}"
    @options_help = ''
  end

  def argument(name, &block)
    @arguments << Argument.new(name, block)
    @args_help << " [#{name}]"
  end

  def option(short_name, full_name, help_text, &block)
    @options << Option.new(short_name, full_name, nil, block)
    @options_help << "\n    -#{short_name}, --#{full_name} #{help_text}"
  end

  def option_with_parameter(short_name, full_name, help_text, param, &block)
    @options << Option.new(short_name, full_name, param, block)
    @options_help << "\n    -#{short_name}, --#{full_name}=#{param} "
    @options_help << help_text
  end

  def help
    @args_help + @options_help
  end

  def parse(command_runner, argv)
    arguments_dup = @arguments.dup
    argv.each do |arg|
      if arg.start_with?('--')
        long_name_option_call(command_runner, arg)
      elsif arg.start_with?('-')
        short_name_option_call(command_runner, arg)
      else
        arguments_dup.shift.parse(command_runner, arg)
      end
    end
  end

  private

  def long_name_option_call(command_runner, arg)
    call_parameters = arg[2..-1].split('=')
    @options.each do |opt|
      next unless opt.full_name == call_parameters[0]
      
      call_parameters[1] = true unless call_parameters[1]
      opt.parse(command_runner, call_parameters[1])
    end
  end

  def short_name_option_call(command_runner, arg)
    @options.each do |opt|
      next unless opt.short_name == arg[1]

      opt.short_name == arg[1]
      option_parameter = arg[2..-1]
      option_parameter = true if option_parameter == ''
      opt.parse(command_runner, option_parameter)
    end
  end
end