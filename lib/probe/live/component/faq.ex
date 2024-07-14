defmodule Probe.Live.Component.Faq do
  use Probe, :live_component

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-md mx-auto">
      <h1 class="text-4xl font-bold text-gray-800 dark:text-gray-200">FAQ</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-4">
        All the things you wanted to know about probe.sh, and maybe even a few you didn't.
      </p>

      <ul class="mt-8 space-y-4">
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">What is probe.sh?</p>
          <p class="text-gray-600 dark:text-gray-400">
            probe.sh is a service for testing WireGuard® connectivity that is designed to run
            using common tools available on most operating systems.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">How does it work?</p>
          <p class="text-gray-600 dark:text-gray-400">
            When you run a test, your machine downloads and executes a script that sends
            packets crafted to look like WireGuard traffic to the probe.sh server. If all
            WireGuard message types are received, the test is successful.
            Otherwise, the test fails.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">
            Is it reliable?
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            probe.sh attempts to detect if your WireGuard packets are being dropped on their way from
            your device to the probe.sh server. This can happen for a number of reasons, but
            we've found it's most commonly due to either your local network or your ISP. However,
            some DPI systems could trigger a false positive result if they filter traffic using
            more advanced techniques than WireGuard header matching. We
            <.link
              navigate="https://www.github.com/firezone/probe"
              class="text-blue-600 dark:text-blue-400 hover:no-underline underline"
            >
              welcome PRs
            </.link>
            to improve our detection methods.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">
            What can I do if my ISP is blocking WireGuard?
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            Most ISPs block WireGuard by dropping packets that look like WireGuard traffic. To get around
            this, you can try using a different port or obfuscating the WireGuard
            traffic in another transport.
            <.link
              navigate="https://www.firezone.dev?utm_source=probe"
              class="text-blue-600 dark:text-blue-400 hover:no-underline underline"
              target="_blank"
            >
              Firezone
            </.link>
            is one such tool that does this by encoding WireGuard traffic inside <.link
              navigate="https://www.rfc-editor.org/rfc/rfc8656#name-channels"
              class="text-blue-600 dark:text-blue-400 hover:no-underline underline"
            >TURN ChannelData messages</.link>, for example.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">
            What data do you collect?
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            We care deeply about user privacy. No IP addresses or personal data is collected
            when you use the probe.sh service. We collect anonymized, aggregated statistics related
            to each test that consists of the following:
            <ul class="list-disc list-inside m-4 text-gray-600 dark:text-gray-400">
              <li>Test result for each WireGuard message type</li>
              <li>Timestamp</li>
              <li>IP location</li>
              <li>Name of your ISP</li>
            </ul>
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">
            Does probe support IPv6?
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            Unfortunately not yet. We will support IPv6 when Fly.io supports public IPv6 routing for UDP.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">Who built it?</p>
          <p class="text-gray-600 dark:text-gray-400">
            probe.sh was built by the team behind <.link
              navigate="https://www.firezone.dev?utm_source=probe"
              class="text-blue-600 dark:text-blue-400 hover:no-underline underline"
              target="_blank"
            >Firezone</.link>.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">
            Why did you build this?
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            We built probe.sh to help users test their WireGuard connections and to help us
            understand how WireGuard is being blocked around the world. Our goal is to share
            this data with the community to help users troubleshoot WireGuard connectivity issues.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">Can I view the source?</p>
          <p class="text-gray-600 dark:text-gray-400">
            Yes! The entire source code for this project (including test scripts) is <.link
              navigate="https://www.github.com/firezone/probe"
              class="text-blue-600 dark:text-blue-400 hover:no-underline underline"
              target="_blank"
            >available on GitHub</.link>.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">
            I think I found a bug. Where can I report it?
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            Please <.link
              navigate="https://www.firezone.dev?utm_source=probe"
              class="text-blue-600 dark:text-blue-400 hover:no-underline underline"
              target="_blank"
            >open a GitHub issue</.link>.
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            If you think you've found a security vulnerability,
            please <.link
              navigate="https://www.github.com/firezone/probe/security/advisories/new"
              class="text-blue-600 dark:text-blue-400 hover:no-underline underline"
            >
              open a security advisory on GitHub
            </.link>.
          </p>
        </li>
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">
            How do you locate my IP address?
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            probe.sh uses GeoLite2 data created by <.link
              navigate="https://www.maxmind.com"
              class="text-blue-600 dark:text-blue-400 hover:no-underline underline"
              target="_blank"
            >
                MaxMind</.link>.
          </p>
        </li>
      </ul>
    </div>
    """
  end
end
