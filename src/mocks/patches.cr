# This file contains patches for the standard library that integrates this shard better.
# Changes in this file *should not* break existing functionality.
# Comments should indicate why the patch is needed.

# Patch for `Process` with regards to "lazily" defined instance and class variables.
# It's very likely the `Process` class will be mocked.
# These variables are defined via `||=`, making them nillable.
# The method returns this expression as a value, which it cannot determine the type of.
# It causes the following error:
#
# ```
# In /usr/share/crystal/src/process.cr:374:5
#
#  374 | @channel ||= Channel(Exception?).new
#  ^-------
# Error: can't infer the type of instance variable '@channel' of Process
# ```
#
# This patch explicitly specifies the type of the variables.
class ::Process
  @channel : Channel(Exception?)?

  @@after_fork_child_callbacks : Array(-> Nil)?
end
