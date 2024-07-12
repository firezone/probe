defmodule Probe.Live.Component.Faq do
  use Probe, :live_component

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-md mx-auto">
      <h1 class="text-4xl font-bold text-gray-800 dark:text-gray-200">FAQ</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-4">
        All the things you wanted to know about Probe, and maybe even a few you didn't.
      </p>

      <ul class="mt-8 space-y-4">
        <li>
          <p class="text-lg font-semibold text-gray-800 dark:text-gray-200">What is Probe?</p>
          <p class="text-gray-600 dark:text-gray-400">
            Probe is a testing service for WireGuard® connectivity.
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
            Probe attempts to detect if your WireGuard traffic is being blocked on its way from
            your device to the probe.sh server. This can happen for a number of reasons, but
            we've found it's most commonly due to either your local network or your ISP. However,
            some DPI systems could trigger a false positive result if they block using
            more advanced techniques. We
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
            What data do you collect?
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            We care deeply about user privacy. No IP addresses or personal data is collected
            when you use the Probe service. We collect anonymized, aggregated statistics related
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
            Probe was built by the team behind <.link
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
            We built Probe to help users test their WireGuard connections and to help us
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
            Probe uses GeoLite2 data created by <.link
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
