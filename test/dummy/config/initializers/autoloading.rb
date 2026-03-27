# frozen_string_literal: true

module Processes; end

Rails.autoloaders.main.push_dir(Rails.root.join('app/processes'), namespace: Processes)
