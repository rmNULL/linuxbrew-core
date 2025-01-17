class Glooctl < Formula
  desc "Envoy-Powered API Gateway"
  homepage "https://docs.solo.io/gloo/latest/"
  url "https://github.com/solo-io/gloo.git",
      :tag      => "v1.3.29",
      :revision => "86852f3d7a9756f5d6d88eaab72470cd05cb5bf5"
  head "https://github.com/solo-io/gloo.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "a2430511c1c083f1684299b34b951497a9e0ddec8d41275f397821803e11f911" => :catalina
    sha256 "bd7018e4d7d41ab67314c2aba9023058d48d86ebe0da8f59de9f9f5a70a5cffe" => :mojave
    sha256 "357c455029d4d08d22e94f69187f5c2087bc7ab2e719cccc90cb606e6348962f" => :high_sierra
    sha256 "7eab45d36a4f1d2e9dd3728d8cf080d68e207bb40554c4114ec9239910a44136" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/solo-io/gloo"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      system "make", "glooctl", "TAGGED_VERSION=v#{version}"
      bin.install "_output/glooctl"
    end
  end

  test do
    run_output = shell_output("#{bin}/glooctl 2>&1")
    assert_match "glooctl is the unified CLI for Gloo.", run_output

    version_output = shell_output("#{bin}/glooctl version 2>&1")
    assert_match "Client: {\"version\":\"#{version}\"}", version_output

    version_output = shell_output("#{bin}/glooctl version 2>&1")
    assert_match "Server: version undefined", version_output

    # Should error out as it needs access to a Kubernetes cluster to operate correctly
    status_output = shell_output("#{bin}/glooctl get proxy 2>&1", 1)
    assert_match "failed to create kube client", status_output
  end
end
