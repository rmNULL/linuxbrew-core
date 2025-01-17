class Click < Formula
  desc "The command-line interactive controller for Kubernetes"
  homepage "https://github.com/databricks/click"
  url "https://github.com/databricks/click/archive/v0.5.3.tar.gz"
  sha256 "68feaa0d2a0c5b3a110eedd393949a89d6f80583eb25289161c0b91714097bed"
  head "https://github.com/databricks/click.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "6bced21af1d4a16b96986fccbab5781f1aae9d9816ce12fdbb299f70b8711229" => :catalina
    sha256 "7ac283d05682f3cf9698b324fc749c7a3281048e3789ab0af61f01c649eebf7d" => :mojave
    sha256 "e1b015903b819bc7f0bde965ca968457f2cac039001abc040ed9652e642fabe7" => :high_sierra
    sha256 "e788021a40b1820c2beebef629c3e7c0bf8127eb4536bebc7e5dc5f8ed28dc58" => :x86_64_linux
  end

  depends_on "rust" => :build
  depends_on "tcl-tk" unless OS.mac?

  uses_from_macos "expect" => :test

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    mkdir testpath/"config"
    # Default state configuration file to avoid warning on startup
    (testpath/"config/click.config").write <<~EOS
      ---
      namespace: ~
      context: ~
      editor: ~
      terminal: ~
    EOS

    # Fake K8s configuration
    (testpath/"config/config").write <<~EOS
      apiVersion: v1
      clusters:
        - cluster:
            insecure-skip-tls-verify: true
            server: 'https://localhost:6443'
          name: test-cluster
      contexts:
        - context:
            cluster: test-cluster
            user: test-user
          name: test-context
      current-context: test-context
      kind: Config
      preferences:
        colors: true
      users:
        - name: test-cluster
          user:
            client-certificate-data: >-
              invalid
            client-key-data: >-
              invalid
    EOS

    # This test cannot test actual K8s connectivity, but it is enough to prove click starts
    (testpath/"click-test").write <<~EOS
      spawn "#{bin}/click" --config_dir "#{testpath}/config"
      expect "*\\[*none*\\]* *\\[*none*\\]* *\\[*none*\\]* >"
      send "quit\\r"
    EOS
    system "expect", "-f", "click-test"
  end
end
