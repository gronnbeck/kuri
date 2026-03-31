# frozen_string_literal: true

class WalkAudioBuilder
  FFMPEG = ENV.fetch("FFMPEG_BIN", "ffmpeg")

  def self.call(walk_session)
    new(walk_session).call
  end

  def initialize(walk_session)
    @session = walk_session
  end

  def call
    check_ffmpeg!

    Dir.mktmpdir("walk_audio") do |dir|
      inner_silence = generate_silence(dir, "inner_silence.mp3", @session.inner_pause_ms / 1000.0)
      outer_silence = generate_silence(dir, "outer_silence.mp3", @session.outer_pause_ms / 1000.0)

      segments = build_segment_list(dir, inner_silence, outer_silence)
      raise "No audio found. Add items with generated audio first." if segments.empty?

      output = File.join(dir, "walk.mp3")
      concat_with_ffmpeg(segments, output, dir)

      @session.audio.attach(
        io:           File.open(output),
        filename:     "walk_#{@session.id}.mp3",
        content_type: "audio/mpeg"
      )
    end

    @session.update!(status: :ready)
  rescue => e
    @session.update!(status: :failed)
    raise
  end

  private

  def check_ffmpeg!
    _, _, status = Open3.capture3(FFMPEG, "-version")
    raise "ffmpeg not found. Install it with: brew install ffmpeg" unless status.success?
  rescue Errno::ENOENT
    raise "ffmpeg not found. Install it with: brew install ffmpeg"
  end

  def generate_silence(dir, filename, duration_secs)
    path = File.join(dir, filename)
    cmd  = [
      FFMPEG, "-y",
      "-f", "lavfi",
      "-i", "anullsrc=r=44100:cl=mono",
      "-t", duration_secs.to_s,
      "-q:a", "9",
      "-acodec", "libmp3lame",
      path
    ]
    _, stderr, status = Open3.capture3(*cmd)
    raise "ffmpeg silence generation failed: #{stderr.lines.last&.strip}" unless status.success?
    path
  end

  def build_segment_list(dir, inner_silence, outer_silence)
    segments = []
    counter  = 0

    @session.walk_session_items.each do |wsi|
      audio_segs = wsi.audio_segments
      next if audio_segs.empty?

      segments << outer_silence if segments.any?

      audio_segs.each_with_index do |seg, idx|
        path = write_audio_segment(dir, seg, counter += 1)
        segments << path if path
        segments << inner_silence if idx < audio_segs.size - 1
      end
    end

    segments.compact
  end

  def write_audio_segment(dir, seg, counter)
    attachment = case seg
    when ConversationAudio then seg.audio
    when VerbAudio         then seg.audio
    when PhraseCard        then seg.audio
    end

    return nil unless attachment&.attached?

    path = File.join(dir, "seg_#{counter}.mp3")
    File.binwrite(path, attachment.download)
    path
  rescue => e
    Rails.logger.warn("WalkAudioBuilder: skipping segment #{counter}: #{e.message}")
    nil
  end

  def concat_with_ffmpeg(segments, output, dir)
    list_path = File.join(dir, "filelist.txt")
    File.write(list_path, segments.map { |f| "file '#{f}'" }.join("\n"))

    cmd = [
      FFMPEG, "-y",
      "-f", "concat", "-safe", "0",
      "-i", list_path,
      "-acodec", "libmp3lame", "-q:a", "4",
      output
    ]
    _, stderr, status = Open3.capture3(*cmd)
    raise "ffmpeg concat failed: #{stderr.lines.last&.strip}" unless status.success?
  end
end
