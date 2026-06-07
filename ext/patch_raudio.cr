require "file_utils"

# raudio's standalone TRACELOG defaults to printf(__VA_ARGS__), while its log
# call sites usually omit trailing newlines. Generate a patched copy that emits
# one line per log message and flushes stdout, without modifying upstream files.
source_path = ARGV[0]? || "raudio/src/raudio.c"
target_path = ARGV[1]? || "build/raudio.c"

source = File.read(source_path)

# Keep the match loose enough for whitespace-only upstream changes, but fail if
# the TRACELOG shape changes so much that this local patch may no longer apply.
original_trace_log_pattern = /^([ \t]*#[ \t]*define[ \t]+TRACELOG\(level,[ \t]*\.\.\.\)[ \t]+)printf[ \t]*\([ \t]*__VA_ARGS__[ \t]*\)[ \t]*$/m
patched_trace_log_pattern = /^[ \t]*#[ \t]*define[ \t]+TRACELOG\(level,[ \t]*\.\.\.\)[ \t]+.*fflush[ \t]*\([ \t]*stdout[ \t]*\).*$/m
patched_trace_log = "\\1do { printf(__VA_ARGS__); printf(\"\\n\"); fflush(stdout); } while (0)"

patched =
  if source.match(patched_trace_log_pattern)
    source
  else
    source.sub(original_trace_log_pattern, patched_trace_log)
  end

if patched == source && !source.match(patched_trace_log_pattern)
  STDERR.puts "Failed to patch TRACELOG in #{source_path}"
  exit 1
end

FileUtils.mkdir_p(File.dirname(target_path))
File.write(target_path, patched)
