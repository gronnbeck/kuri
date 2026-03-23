# frozen_string_literal: true

# Injects a countdown JS snippet that auto-navigates to next_url after 3 seconds.
# Works together with ExerciseResult which renders the #sp-countdown element.
#
# Usage:
#   render Views::Components::ExerciseAutoAdvance.new(
#     next_url:         helpers.practice_sentence_patterns_exercise_path,
#     countdown_prefix: "Next exercise in"   # default: "Next in"
#   )
class Views::Components::ExerciseAutoAdvance < ApplicationView
  def initialize(next_url:, countdown_prefix: "Next in")
    @next_url         = next_url
    @countdown_prefix = countdown_prefix
  end

  def view_template
    script do
      raw Phlex::SGML::SafeValue.new(<<~JS)
        (function() {
          var remaining = 3;
          var el = document.getElementById('sp-countdown');
          function tick() {
            if (remaining <= 0) { window.location.href = '#{@next_url}'; return; }
            if (el) el.textContent = '#{@countdown_prefix} ' + remaining + '...';
            remaining--;
            setTimeout(tick, 1000);
          }
          tick();
        })();
      JS
    end
  end
end
