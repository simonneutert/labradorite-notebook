# frozen_string_literal: true

threads_count = Integer(ENV.fetch('PUMA_THREADS', 5))
threads threads_count, threads_count

workers 0 # single process — avoids all SQLite/Sequel fork-safety issues above
# (also means: no preload_app!, no on_worker_boot needed)

# Runs after Puma has fully stopped accepting requests — safe point for cleanup,
# and doesn't fight Puma's own TERM/INT handling the way an app-level Signal.trap does.
on_stopped do
  SearchIndex::Database.reset_shared! if defined?(SearchIndex::Database)
end
