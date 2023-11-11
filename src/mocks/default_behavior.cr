module Mocks
  # Controls the behavior used by stubbed methods.
  # This behavior is only applied when there isn't an applicable stub
  # or the stub yielded to the original method.
  #
  # One argument should be passed along with the annotation,
  # which is a symbol identifying the behavior.
  #
  # - `:original` - Call the original method.
  # - `:unexpected` - Raise an `UnexpectedMessage` error (default).
  annotation DefaultBehavior
  end
end
