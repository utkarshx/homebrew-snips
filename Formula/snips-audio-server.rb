class SnipsAudioServer < Formula
  desc "Snips Audio Server"
  homepage "https://snips.ai"

  url "ssh://git@github.com/snipsco/snips-platform.git",
    :using => :git, :tag => "0.64.0", :revision => "6df6a46d5ccfb312163c60a0ce2b3b90d8136b54"

  head "ssh://git@github.com/snipsco/snips-platform.git",
    :using => :git, :branch => "develop"

  bottle do
    root_url "https://homebrew.snips.ai/bottles"
    cellar :any
    sha256 "fe73c1ca09153da20a17fa1853a42ba72b233fd25730b25b56a485f63cb43fba" => :el_capitan
  end

  option "with-debug", "Build with debug support"
  option "without-completion", "bash, zsh and fish completion will not be installed"

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "portaudio"
  depends_on "snips-platform-common"

  def install
    target_dir = build.with?("debug") ? "target/debug" : "target/release"

    args = %W[--root=#{prefix}]
    args << "--path=snips-audio-server/snips-audio-server"
    args << "--debug" if build.with? "debug"

    system "cargo", "install", *args

    bin.install "#{target_dir}/snips-audio-server"

    if build.with? "completion"
      bash_completion.install "#{target_dir}/completion/snips-audio-server.bash"
      fish_completion.install "#{target_dir}/completion/snips-audio-server.fish"
      zsh_completion.install "#{target_dir}/completion/_snips-audio-server"
    end
  end

  plist_options :manual => "snips-audio-server -c #{HOMEBREW_PREFIX}/etc/snips.toml"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/snips-audio-server</string>
          <string>-c</string>
          <string>#{etc}/snips.toml</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/snips/snips-audio-server.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/snips/snips-audio-server.log</string>
        <key>ProcessType</key>
        <string>Interactive</string>
      </dict>
    </plist>
  EOS
  end

  test do
    assert_equal "snips-audio-server #{version}\n", shell_output("#{bin}/snips-audio-server --version")
  end
end
