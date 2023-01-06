# frozen_string_literal: true

def hello_world
  'Hello world!'
end

def no_coverage
  'I have no coverage!'
end

hello_world if __FILE__ == $PROGRAM_NAME
